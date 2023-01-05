import sys;
import math;
import numpy;

if __name__ == '__main__':
    x1=float(sys.argv[1])
    y1=float(sys.argv[2])
    x2=float(sys.argv[3])
    y2=float(sys.argv[4])
    k=float((y1-y2)/(x1-x2))
    b=float(y2-k*x2)
    print(k)
    print(b)