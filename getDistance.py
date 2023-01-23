import sys;
import math;
import numpy;

if __name__ == '__main__':
    x1=float(sys.argv[1])
    y1=float(sys.argv[2])
    x2=float(sys.argv[3])
    y2=float(sys.argv[4])
    d=math.sqrt((x1-x2)*(x1-x2)-(y1-y2)*(y1-y2))
    print(d)
