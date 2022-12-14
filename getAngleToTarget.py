# This is a sample Python script.
import sys;
import math;
# Press Shift+F10 to execute it or replace it with your code.
# Press Double Shift to search everywhere for classes, files, tool windows, actions, and settings.


def print_angle(currentAngle, targetAngle):
    # Use a breakpoint in the code line below to debug your script.
    print(sys.argv[len(sys.argv)-1])
    print(sys.argv[len(sys.argv) - 2])
    print("current angle and target angle")
    print(currentAngle)  # Press Ctrl+F8 to toggle the breakpoint.
    print(targetAngle)

# Press the green button in the gutter to run the script.
if __name__ == '__main__':
    targetX=float(sys.argv[len(sys.argv)-2])
    targetY=float(sys.argv[len(sys.argv)-1])


    positionX=float(sys.argv[15])
    positionY=float(sys.argv[17])
    positionZ = float(sys.argv[19])
    orientationX=float(sys.argv[22])
    orientationY = float(sys.argv[24])
    orientationZ = float(sys.argv[26])
    orientationW =float( sys.argv[28])
    twistLinearX=float(sys.argv[106])
    twistLinearY = float(sys.argv[108])
    twistLinearZ = float(sys.argv[110])
    angularX=float(sys.argv[113])
    angularY = float(sys.argv[115])
    angularZ = float(sys.argv[117])
    angle = orientationZ

    print('orientationX=',orientationX,' degrees=',math.degrees(float(orientationX)),'asin=',math.degrees(math.asin(orientationX)))
    print('orientationY=', orientationY,' degrees=',math.degrees(float(orientationY)),'asin=',math.degrees(math.asin(orientationY)))
    print('orientationZ=', orientationZ,' degrees=',math.degrees(float(orientationZ)),'asin=',math.degrees(math.asin(orientationZ)),'acos=',math.degrees(math.acos(orientationZ)),'atan=',math.degrees(math.atan(orientationZ)))
    print('orientationW=', orientationW,' degrees=',math.degrees(float(orientationW)),'asin=',math.degrees(math.asin(orientationW)))
    print('twistLinearX=', twistLinearX,' degrees=',math.degrees(float(twistLinearX)),'asin=',math.degrees(math.asin(twistLinearX)))
    print('twistLinearY=', twistLinearY,' degrees=',math.degrees(float(twistLinearY)),'asin=',math.degrees(math.asin(twistLinearY)))
    print('twistLinearZ=', twistLinearZ,' degrees=',math.degrees(float(twistLinearZ)),'asin=',math.degrees(math.asin(twistLinearZ)))
    print('angularX=', angularX,' degrees=',math.degrees(float(angularX)),'asin=',math.degrees(math.asin(angularX)))
    print('angularY=', angularY,' degrees=',math.degrees(float(angularY)),'asin=',math.degrees(math.asin(angularY)))
    print('angularZ=', angularZ,' degrees=',math.degrees(float(angularZ))),'asin=',math.degrees(math.asin(angularZ))

    currentAngle=2*math.degrees(math.asin(orientationZ))
    targetAngle=math.degrees(math.atan((targetY-positionY)/(targetX-positionX)))
    print_angle(currentAngle,targetAngle)

# See PyCharm help at https://www.jetbrains.com/help/pycharm/
