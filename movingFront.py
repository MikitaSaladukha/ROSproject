import sys;
import math;
import numpy;

if __name__ == '__main__':
    closest=3.6
    closestAngle=0
    startingI=25
    Start=sys.argv[startingI]
    angle=0
    N=0
    side=sys.argv[-2]
    close = False
    far = True
    for i in range(startingI, 720+startingI, 2):

        if sys.argv[i]!='.inf' and far:
            far=(float(sys.argv[i])>float(sys.argv[-1]))
        if sys.argv[i] != '.inf' and (angle>275 or angle<85):
            if (close==False):close=(float(sys.argv[i])<float(sys.argv[-2]))

        angle = angle + 1
    if close: print("obstacle in front")
    if far: print("far")
    if close==False and far==False: print("moving")




