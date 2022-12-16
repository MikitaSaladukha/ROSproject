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
    rollingSpeed=0.05*numpy.sign(float(angle1) -float(angle2))
    print("'{linear:  {x: 0.0, y: 0.0, z: 0.0}, angular: {x: 0.0,y: 0.0,z:",rollingSpeed,"}}'")
