import sys;
import math;
import numpy;

if __name__ == '__main__':
    closest=3.6
    startingI=25
    Start=sys.argv[startingI]
    angle=0
    N=0
    side="none"
    for i in range(startingI, 720+startingI, 2):
        close=False
        if sys.argv[i]!='.inf':
            close= ((float(sys.argv[-2])<=float(sys.argv[i])) and (float(sys.argv[i])<=float(sys.argv[-1])))
        #print("distanse=",sys.argv[i], " in angle=",angle," close=",close)
        if close:
            if (angle <=90 | angle>=270):
                if angle <=90: side="left_side"
                if angle >= 270: side = "right_side"
                print(angle)
                print(float(sys.argv[i]))
                N=N+1
        angle = angle + 1
        print(N)
        print(side)


