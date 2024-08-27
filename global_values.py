import sys


Xmin = 0
Xmax = 5
Ymin = 0
Ymax = 5
stepX = 1
stepY = 1
Xtarget = 2
Ytarget = 3
x = Xmin
y = Ymin

arrayX = []
arrayY = []

def set_arrays_borders():
    x = Xmin
    y = Ymin
    while x < Xmax:
        arrayX.append([float(x), float(x + stepX)])
        while y < Ymax:
            arrayY.append([float(y), float(y + stepY)])
            y = y + stepY
        x = x + stepX


if __name__ == '__main__':

    Xmin=float(sys.argv[0])
    Xmax = float(sys.argv[1])
    Ymin=float(sys.argv[2])
    Ymax = float(sys.argv[3])
    stepX=float(sys.argv[4])
    stepY = float(sys.argv[5])
    Xtarget = float(sys.argv[6])
    Ytarget = float(sys.argv[7])
    print("global values set")