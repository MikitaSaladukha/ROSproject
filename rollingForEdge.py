import sys;
import math;
import numpy;
#copy from rollingForOrtogonal.py
if __name__ == '__main__':
    closest=3.6
    closestAngle=0
    startingI=25
    Start=sys.argv[startingI]
    angle=0
    N=0
    side=sys.argv[-1]

    for i in range(startingI, 720+startingI, 2):

        if sys.argv[i]!='.inf':
            if closest > float(sys.argv[i]):
                closest = float(sys.argv[i])
                closestAngle = angle

        angle = angle + 1
    print(closestAngle)
    if (side=="right_side"):
        if closestAngle<265 and closestAngle>=258:
            print("good")
        if closestAngle>=265 or closestAngle<90:
            print("round_plus")
        if closestAngle<258 and closestAngle>=90:
            print("round_minus")
    if (side=="left_side"):
        if closestAngle<=103 and closestAngle>95:
            print("good")
        if closestAngle>103 and closestAngle<=270:
            print("round_plus")
        if closestAngle<=95 or closestAngle>270:
            print("round_minus")


