import cv2
import numpy as np
import sys

#name = "tri"
#name = "circle"
#name = "empty"
name = "top"
name = "left"

img = cv2.imread(f"{name}.png", 1)

#img = cv2.resize(img, (32,32))

(imgB, imgG, imgR) = cv2.split(img)


with open(f"{name}.mem", "w") as f:
    for i in range(img.shape[0]):
        for j in range(img.shape[1]):
            if imgB[i][j] > 150:
                if imgG[i][j] > 150:
                    if imgR[i][j] > 150:
                        f.write("111\n")
                    else:
                        f.write("011\n")
                else:
                    if imgR[i][j] > 150:
                        f.write("101\n")
                    else:
                        f.write("001\n")
            else:
                if imgG[i][j] > 150:
                    if imgR[i][j] > 150:
                        f.write("110\n")
                    else:
                        f.write("010\n")
                else:
                    if imgR[i][j] > 150:
                        f.write("100\n")
                    else:
                        f.write("000\n")

