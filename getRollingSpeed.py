import sys;
import math;
import numpy;

if __name__ == '__main__':
    #angle1-target
    #angle2-current
    angle1=float(sys.argv[-2])
    angle2=float(sys.argv[-1])
    kostil=False
    if angle1<0.0 and angle1>=-90.0 and angle2>0.0 and angle2<=90.0:
        kostil=True

    #print("angle1=",angle1)
    #print("angle2=", angle2)
    #print("sing angle1",numpy.sign(angle1)==-1)
    #print("sing angle2", numpy.sign(angle2))
    if numpy.sign(angle1) != numpy.sign(angle2):
        if numpy.sign(angle1) < 0:
            angle1=angle1+360
        else:  angle2=angle2+360
    rollingSpeed=0.05*numpy.sign(float(angle1) -float(angle2))
    if kostil: rollingSpeed=-0.05
    print("'{linear:  {x: 0.0, y: 0.0, z: 0.0}, angular: {x: 0.0,y: 0.0,z:",rollingSpeed,"}}'")
    #print ("  angle1>=-90.0 and angle2>0.0 and angle2<=90.0: numpy.sign(angle1)==-1 :" , angle1>=-90.0, angle2>0.0 , angle2<=90.0,angle1)