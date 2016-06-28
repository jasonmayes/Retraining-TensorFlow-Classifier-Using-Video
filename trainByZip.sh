#!/bin/bash
#
# Script to convert all MP4 videos in a zip archive to JPG frames at a desired
# FPS with unique names. It will then retrain the top layers of a binary image
# classifier using TensorFlow using these extracted images. Please change the
# location of the TensorFlow install on line 51: TENSOR_FLOW_PATH.
#
# NOTE:
# 1) Assumes max frames per video is no more than 999999.
# 2) Assumes you have already installed TensorFlow. See 
#    https://github.com/jasonmayes/Tensor-Flow-on-Google-Compute-Engine if not.
#
# @author Jason Mayes - www.jasonmayes.com
#
# IMPORTANT: Zip file must consist of folders of videos only. These folders
# must not be inside any parent folder. For example this is a valid zip
# structure as all mp4s are only 1 level deep:
#
#  myfile.zip
#  -- object/
#  ------ videoOfObject.mp4
#  ------ videoOfObject2.mp4
#  -- Not Object/
#  ------ videoOfEnvironment.mp4
#  ------ videoOfEnvironment2.mp4
#
# However the following structure IS NOT VALID:
#  myfile.zip
#  -- some top level folder                             <-- This is not allowed.
#  ------ object/
#  ------------ videoOfObject.mp4
#  ------------ videoOfObject2.mp4
#  ------ Not Object/
#  ------------ videoOfEnvironment.mp4
#  ------------ videoOfEnvironment2.mp4
#
# ************************** Usage **************************
#
# Usage Example 1: Create 5 images every second of video (ie every 200ms)
# script.sh 001_Unique_ID /home/user/zipFile.zip 5
#
# Can also optionally pass scale as 3nd parameter. For example:
# script.sh 001_Unique_ID /home/user/zipFile.zip 5 320:-1
# In this case it would resize the width to be 320px and keep aspect ratio for
# height.
#
# Once complete your classifier files will  be available for usage in:
# /tmp/classifiers/<unique_id>
# Where <unique_id> is the unique ID you specified when calling the script.
#


# TODO: PLEASE SET YOUR CORRECT PATH TO TENSORFLOW DIRECTORY:
TENSOR_FLOW_PATH="/home/jasonmayes/tensorflow/tensorflow"


###########################DO NOT EDIT BELOW THIS LINE##########################
REQ_ID="$1"
ZIP_FILE="$2"
DIRECTORY=$(dirname "${ZIP}")
FPS="$3"
SCALE=""

if [ ! -z $4 ]
  then
    SCALE="scale="$4","
fi

# Unzip the zip to its own directory.
unzip "$ZIP_FILE"

# Remove any JPGs from previous runs.
find "$DIRECTORY" -name '*.jpg' | xargs rm

# Find any MP4s even in sub dirs, and store results in array.
# This is important as ffmpeg refuses to excute more than once
# if using a regular loop using find.
unset a i
while IFS= read -r -d '' file; do
  a[i++]="$file"
done < <(find "$DIRECTORY" -name '*.mp4' -type f -print0)
# Now itterate over any MP4s found applying FFMPEG commands.
for n in "${a[@]}"
do
   :
   echo $n
   # Replace .mp4 with blank to remove.
   FILEPREFIX=$(echo $n | sed 's/.mp4//g')
   # Generate frames every quarter of a second assuming 25fps
   ffmpeg -i "$FILEPREFIX".mp4 -y -an -q 0 -vf "$SCALE"fps="$FPS" "$FILEPREFIX"_%06d.jpg
done
 
# Delete original mp4s
find "$DIRECTORY" -name '*.mp4' | xargs rm

"$TENSOR_FLOW_PATH"/bazel-bin/tensorflow/examples/image_retraining/retrain --image_dir "$DIRECTORY"
mkdir /tmp/classifiers/"$REQ_ID"
cp /tmp/output_graph.pb /tmp/classifiers/"$REQ_ID"
cp /tmp/output_labels.txt /tmp/classifiers/"$REQ_ID"
rm -rf /tmp/bottleneck/

# Uncomment and edit to copy resulting clasifier to Google cloud storage for download.
#gsutil cp -r "/tmp/classifiers/$REQ_ID" "gs://<YOUR BUCKET NAME>/classifiers/$REQ_ID"
