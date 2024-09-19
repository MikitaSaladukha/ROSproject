import sys;
import math;
import numpy;

if __name__ == '__main__':
    closest=3.6
    closestAngle=0
    startingI=25
    Start=sys.argv[startingI]
    angle=0
    for i in range(startingI, 720+startingI, 2):
        if sys.argv[i]!='.inf':
            if closest > float(sys.argv[i]):
                closest = float(sys.argv[i])
                closestAngle = angle

        angle = angle + 1
    print(closestAngle)

    if closestAngle<180:
        print("round_plus")
    if closestAngle>=180:
        print("round_minus")
    if closestAngle < 15 or closestAngle >= 345:
        print("good")



