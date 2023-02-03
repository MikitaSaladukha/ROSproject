import sys;
import math;
import numpy;

if __name__ == '__main__':
    #angle1-target
    #angle2-current
    angle1=float(sys.argv[-2])
    angle2=float(sys.argv[-1])
    if numpy.sign(angle1) == numpy.sign(angle2):
        rollingSpeed=0.03*numpy.sign(float(angle1) -float(angle2))
    else:
        if numpy.sign(angle1) > numpy.sign(angle2):
            rollingSpeed = 0.03
        if numpy.sign(angle1) < numpy.sign(angle2):
            rollingSpeed = -0.03

    if angle1<=0.0 and angle1>=-90.0 and angle2>=0.0 and angle2<=90.0:
        rollingSpeed=-0.03

    if angle1<=90 and angle1>=0 and angle2>=-90 and angle2<=0:
        rollingSpeed=0.03

    print("'{linear:  {x: 0.0, y: 0.0, z: 0.0}, angular: {x: 0.0,y: 0.0,z:",rollingSpeed,"}}'")