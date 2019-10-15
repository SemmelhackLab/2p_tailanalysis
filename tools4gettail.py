from PIL import Image
import numpy as np
import os, csv, math
import pandas as pd


def tif2array(img):
    '''
    :param img: the tiff file time lapse you want to convert to array
    :return: a 3D array
    '''
    tiff = Image.open(img)
    im = []

    for i in range(tiff.n_frames):
       tiff.seek(i)
       #print len(np.array(tiff))
       im.append(np.array(tiff))

    return im


def start_tailpoint(tailfile):

    XY = []

    with open(tailfile) as csvfile:

        filename, file_extension = os.path.splitext(tailfile)
        readCSV = csv.reader(csvfile, delimiter=',')
        headers = readCSV.next()
        X = headers.index('X')
        Y = headers.index('Y')
        # leftv = headers1.index('Left Velocity')
        # rightv = headers1.index('Right Velocity')

        for row in readCSV:
            XY.append(row[X])
            XY.append(row[Y])

    return XY


def get_tailangle(img, XY):

    tailangle = [] # initialize tail angle list

    # loop over each frame of the video
    for i in range(len(img)):
        X = list(np.where(img[i] == 255)[1]) # find the x coordinates of all the skeletonize points in the image
        Y = list(np.where(img[i] == 255)[0]) # find the y coordinates of all the skeletonize points in the image

        if not Y: # if there's no tracked tail in the current frame
            tailangle.append(np.nan)
        elif Y:# if there's tracked tail
            Ymax = int(max(Y)) # find the highest coordinate or the lowest point in the image
            Xmax = int(X[Y.index(Ymax)])  # where is the index of the highest Y and extract its X
            tailangle.append(math.degrees(math.atan2(Ymax - float(XY[1]), Xmax - float(XY[0]))) - 90) # compute the angle

    frame = np.arange(0, len(tailangle))
    tailangle2 = pd.Series(tailangle)
    new_tailangle = tailangle2.interpolate(method='polynomial', order=3) # interpolate missing data

    return new_tailangle, frame