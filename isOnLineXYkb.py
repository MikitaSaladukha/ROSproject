import sys;
import math;
import numpy;

if __name__ == '__main__':
    y=float(sys.argv[1])
    x=float(sys.argv[2])
    k=float(sys.argv[3])
    b=float(sys.argv[4])
    online=((y-k*x+b)<0.02)
    print(online)
