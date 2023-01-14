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
    side=sys.argv[-1]

    for i in range(startingI, 720+startingI, 2):

        if sys.argv[i]!='.inf':
            if closest > float(sys.argv[i]):
                closest = float(sys.argv[i])
                closestAngle = angle

        angle = angle + 1
    print(closestAngle)
    if (side=="right_side"):
        if closestAngle<280 and closestAngle>260:
            print("good")
        if closestAngle>280:
            print("round_plus")
        if closestAngle<260:
            print("round_minus")
    if (side=="left_side"):
        if closestAngle<100 and closestAngle>80:
            print("good")
        if closestAngle>100:
            print("round_plus")
        if closestAngle<80:
            print("round_minus")


