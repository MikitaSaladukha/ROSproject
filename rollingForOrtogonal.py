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
    side=sys.argv[-3]

    for i in range(startingI, 720+startingI, 2):
        close=False
        if sys.argv[i]!='.inf':
            close= ((float(sys.argv[-2])<=float(sys.argv[i])) and (float(sys.argv[i])<=float(sys.argv[-1])))


        if close:
            if closest > float(sys.argv[i]):
                closest = float(sys.argv[i])
                closestAngle = angle

        angle = angle + 1
    if (side=="right_side"):
        if closestAngle<280 and closestAngle>260:
            print("good")
        if closestAngle>280:
            print("round_plus")
        if closestAngle<260:
            print("round_minus")



