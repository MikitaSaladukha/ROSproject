import sys;
import math;
import numpy;

if __name__ == '__main__':
    x=float(sys.argv[1])
    y=float(sys.argv[2])
    k=float(sys.argv[3])
    b=float(sys.argv[4])
    online=(math.fabs(y-k*x-b)<=0.115)
    print(online)
