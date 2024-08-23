import sys;
import math;

if __name__ == '__main__':
    closest = 3.6
    closestAngle = 0
    startingI=25
    Start=sys.argv[startingI]
    angle=0
    N=0
    side="none"
    close = False
    closeFound=False
    for i in range(startingI, 720+startingI, 2):
        if sys.argv[i]!='.inf':
            if closest > float(sys.argv[i]):
                closest = float(sys.argv[i])
                closestAngle = angle

        angle = angle + 1
    if closest<=float(sys.argv[-1]):
        if closestAngle <= 180: side = "left_side"
        if closestAngle > 180: side = "right_side"
    print(closest)
    print(close)
    print(closestAngle)
    print(side)


