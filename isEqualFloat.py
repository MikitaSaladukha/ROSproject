import sys;
import math;
if __name__ == '__main__':
    float1=float(sys.argv[len(sys.argv)-2])
    float2=float(sys.argv[len(sys.argv)-1])
    if  (math.fabs(float1-float2)<5.0):
        print("true")
    else:
        print("false")