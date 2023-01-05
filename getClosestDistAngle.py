import sys;
import math;
import numpy;

if __name__ == '__main__':
    closest=3.6
    startingI=25
    Start=sys.argv[startingI]
    angle=0
    N=0
    for i in range(startingI, 720+startingI, 2):
        close=False
        if sys.argv[i]!='.inf':
            close= float(sys.argv[i])<=float(sys.argv[-1])
        #print("distanse=",sys.argv[i], " in angle=",angle," close=",close)
        if close:
            print(angle)
            N=N+1
        angle = angle + 1
        print(N)


