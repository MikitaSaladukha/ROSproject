import sys;
import math;

if __name__ == '__main__':
    reqAngle = int(sys.argv[-1])
    startingI=25
    Start=sys.argv[startingI]
    angle=0
    for i in range(startingI, 720+startingI, 2):
        if reqAngle==angle:
            if sys.argv[i] == '.inf':
                print(3.6)
                break
            else:
                print(sys.argv[i])
                break
        angle = angle + 1



