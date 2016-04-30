#!/bin/bash
CAFFE_ROOT=/home/ubuntu/caffe
DOG_VS_CAT_FOLDER=/home/ubuntu/dogvscat

cd $DOG_VS_CAT_FOLDER
## Download datasets (requires first a login)
#wget https://www.kaggle.com/c/dogs-vs-cats/download/train.zip
#wget https://www.kaggle.com/c/dogs-vs-cats/download/test1.zip

# Unzip train and test data
sudo apt-get -y install unzip
unzip train.zip -d .
unzip test1.zip -d .

# Format data
python create_label_file.py # creates 2 text files with labels for training and validation
./build_datasets.sh # build lmdbs

# Download ImageNet pretrained weights (takes ~20 min)
$CAFFE_ROOT/scripts/download_model_binary.py $CAFFE_ROOT/models/bvlc_reference_caffenet 

# Fine-tune AlexNet architecture (takes ~60 min)
$CAFFE_ROOT/build/tools/caffe train -solver $DOG_VS_CAT_FOLDER/dogvscat_solver.prototxt -weights $CAFFE_ROOT/models/bvlc_reference_caffenet/bvlc_reference_caffenet.caffemodel 

# Classify test dataset
cd $DOGVSCAT_FOLDER
python convert_binaryproto2npy.py
python dogvscat_classify.py # Returns prediction.txt (takes ~20 min)

# A better approach is to train five AlexNets w/init parameters from the same distribution,
# fine-tuned those five, and compute the average of the five networks
