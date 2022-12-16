import sys;
import math;
import numpy;

if __name__ == '__main__':
    angle1=float(sys.argv[-2])
    angle2=float(sys.argv[-1])
    if numpy.sign(angle1) != numpy.sign(angle2):
        if numpy.sign(angle1) < 0:
            angle1=angle1+360
        else:  angle2=angle2+360
    if (math.fabs(angle1 - angle2) < float(sys.argv[len(sys.argv) - 3])):
        print("true")
    else:
        print("false")