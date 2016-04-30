#!/usr/bin/env sh
# Create the imagenet lmdb inputs
# N.B. set the path to the imagenet train + val data dirs

CAFFE_ROOT=/home/ubuntu/caffe
OUTPUT=/home/ubuntu/dogvscat
LABEL_TEXT_ROOT=/home/ubuntu/dogvscat
TRAIN_DATA_ROOT=/home/ubuntu/dogvscat/train/
VAL_DATA_ROOT=/home/ubuntu/dogvscat/train/

# Set RESIZE=true to resize the images to 256x256. Leave as false if images have
# already been resized using another tool.
#RESIZE=false
RESIZE=true
if $RESIZE; then
  RESIZE_HEIGHT=256
  RESIZE_WIDTH=256
else
  RESIZE_HEIGHT=0
  RESIZE_WIDTH=0
fi

echo "Creating train lmdb..."

TOOLS=$CAFFE_ROOT/build/tools

GLOG_logtostderr=1 $TOOLS/convert_imageset \
    --resize_height=$RESIZE_HEIGHT \
    --resize_width=$RESIZE_WIDTH \
    --shuffle \
    $TRAIN_DATA_ROOT \
    $LABEL_TEXT_ROOT/train.txt \
    $OUTPUT/dogvscat_train_lmdb

echo "Creating val lmdb..."

GLOG_logtostderr=1 $TOOLS/convert_imageset \
    --resize_height=$RESIZE_HEIGHT \
    --resize_width=$RESIZE_WIDTH \
    --shuffle \
    $VAL_DATA_ROOT \
    $LABEL_TEXT_ROOT/val.txt \
    $OUTPUT/dogvscat_val_lmdb

echo "Compute image mean..."

$TOOLS/compute_image_mean $OUTPUT/dogvscat_train_lmdb \
  $OUTPUT/dogvscat_mean.binaryproto

echo "Done."
