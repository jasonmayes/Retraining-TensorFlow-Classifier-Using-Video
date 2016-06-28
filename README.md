# Retraining TensorFlow Binary Image Classifier Using MP4 Video

Ah machine learning. Much fun when it works, a nightmare when it does not. Half of the problem is finding enough training material for your classifiers. I figured a great way to do this is to use video as in input source. I made this script to convert all MP4 videos in a zip archive to JPG frames at a desired FPS with unique names. It will then retrain the top layers of a binary image classifier using TensorFlow using these extracted images. About 5 to 10 mins of video shot on your smartphone should do the trick.

By Jason Mayes - www.jasonmayes.com


## Requirements
1. Assumes max frames output per video is no more than 999999.
2. Assumes you have already installed TensorFlow. See https://github.com/jasonmayes/Tensor-Flow-on-Google-Compute-Engine if not for my super fast getting started script.


## Usage

Please change the location of the TensorFlow install on line 51: TENSOR_FLOW_PATH to where you installed TensorFlow to on your system.

IMPORTANT: Zip file must consist of folders of videos only. These folders must not be inside any parent folder. For example this is a valid zip structure as all mp4s are only 1 level deep:
```
myfile.zip
-- object/
------ videoOfObject.mp4
------ videoOfObject2.mp4
-- Not Object/
------ videoOfEnvironment.mp4
------ videoOfEnvironment2.mp4

However the following structure IS NOT VALID:
myfile.zip
-- some top level folder                             <-- This is not allowed.
------ object/
------------ videoOfObject.mp4
------------ videoOfObject2.mp4
------ Not Object/
------------ videoOfEnvironment.mp4
------------ videoOfEnvironment2.mp4
```

### Usage Example 1

Create 5 images every second of video (ie every 200ms)

```script.sh 001_Unique_ID /home/user/zipFile.zip 5```

### Usage Example 2 

Optionally pass scale as 3nd parameter.

```script.sh 001_Unique_ID /home/user/zipFile.zip 5 320:-1```

In this case it would resize the width to be 320px and keep aspect ratio for height.

### Output
Once complete your classifier files will  be available for usage in:

```
/tmp/classifiers/unique_id
```

Where "unique_id" is the unique ID you specified when calling the script.
