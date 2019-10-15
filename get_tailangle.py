from tools4gettail import *
import os
from matplotlib import pyplot as plt
from itertools import izip_longest

maindir = os.listdir('D:\\Semmelhack lab\\002 ANALYSIS\\2p_2dots\\effect of target to competitor\\')
maindir = maindir[13:-1]
print maindir
for fish in maindir:
    input_dir = "D:\\Semmelhack lab\\002 ANALYSIS\\2p_2dots\\effect of target to competitor\\" + fish + '\\tail\\'
    skel_input = input_dir + "skel\\"
    output_dir = input_dir + 'tail results\\'

    tif_files = [file_name for file_name in os.listdir(skel_input) if os.path.splitext(file_name)[1] == '.tif']
    tailfile = [file_name for file_name in os.listdir(input_dir) if 'Tail-XY' in file_name]

    for tif in tif_files:
        print "Processing: ", fish, tif
        img = tif2array(skel_input + tif)
        XY = start_tailpoint(input_dir + tailfile[0])
        XY = [XY[0], XY[1]]  # get the first two points
        tailangle, frame = get_tailangle(img,XY)

        results = izip_longest(frame, tailangle)
        header = izip_longest(['Frame'], ['Tail'])

        filename = os.path.splitext(tif)[0].replace('Skel', 'Tail')
        if not os.path.exists(output_dir):  # create an output directory
            os.makedirs(output_dir)
        with open(output_dir + filename + '.csv', 'wb') as myFile:
            # with open(dir_output + 'Velocity_Acceleration_' + filename + '.csv', 'wb') as myFile:
            wr = csv.writer(myFile, delimiter=',')
            for head in header:
                wr.writerow(head)
            for rows in results:
                wr.writerow(rows)