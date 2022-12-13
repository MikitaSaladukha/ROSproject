import sys;
import math;
import numpy;

if __name__ == '__main__':
    rollingSpeed=0.05*numpy.sign(float(sys.argv[1]) -float(sys.argv[2]))
    print("'{linear:  {x: 0.0, y: 0.0, z: 0.0}, angular: {x: 0.0,y: 0.0,z:",rollingSpeed,"}}'")
