# Set the right path to your model definition file, pretrained model weights,
# and the image you would like to classify.
CAFFE_ROOT = '/home/ubuntu/caffe/'
DOGVSCAT_ROOT = '/home/ubuntu/dogvscat/'
MODEL_FILE = DOGVSCAT_ROOT + 'dogvscat_deploy.prototxt' # architecture
PRETRAINED = DOGVSCAT_ROOT + 'dogvscat_iter_3000.caffemodel' # weights
IMAGES_FOLDER = '/home/ubuntu/dogvscat/test1/'
PREDICTION_FILE = '/home/ubuntu/dogvscat/predictions.txt'

import numpy as np

# Make sure that caffe is on the python path:
import sys
sys.path.insert(0, CAFFE_ROOT + 'python')
import caffe

# Note arguments to preprocess input
#  mean subtraction switched on by giving a mean array
#  input channel swapping takes care of mapping RGB into BGR (CAFFE uses OpenCV which reads it as BGR)
#  raw scaling (max value in the images in order to scale the CNN input to [0 1])
caffe.set_mode_cpu()
net = caffe.Classifier(MODEL_FILE, PRETRAINED,
                       mean=np.load(DOGVSCAT_ROOT + 'dogvscat_mean.npy').mean(1).mean(1),
                       channel_swap=(2,1,0),
                       raw_scale=255,
                       image_dims=(256, 256))

import os
images = os.listdir(IMAGES_FOLDER)
imnums = [int(im[:-4]) for im in images] # to sort by image number
imnums.sort()
NUM_IMAGES = len(images)
BATCH_SIZE = 200
i = 0

f = open(PREDICTION_FILE, 'w')

while i < NUM_IMAGES:
    maximage = min(i + BATCH_SIZE, NUM_IMAGES) - 1
    #print 'Loading images ' + str(i) + ' to ' + str(maximage)
    print 'Loading images {0} to {1}'.format(i, maximage)
    input_images = [ caffe.io.load_image(IMAGES_FOLDER + str(im) + '.jpg') for im in imnums[i : maximage + 1] ]

    # Classify images
    print 'Making predictions'
    prediction = net.predict(input_images, 'false')
    
    for j,p in enumerate(prediction):
        f.write(str(imnums[j]) + ",")
        f.write(str(p.argmax()) + '\n')
        #f.write('{0}\n'.format(p.argmax()))

    i = i + BATCH_SIZE

f.close()
