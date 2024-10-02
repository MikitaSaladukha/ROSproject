from random import random

import global_values
import sys
import xmltodict
import numpy
import random

if __name__ == '__main__':
    x_target = float(sys.argv[1])
    y_target = float(sys.argv[2])
    Xmin=global_values.Xmin
    Xmax = global_values.Xmax
    Ymin= global_values.Ymin
    Ymax = global_values.Ymax
    stepX = global_values.stepX
    stepY = global_values.stepY
    x=Xmin
    y=Ymin
    global_values.set_arrays_borders()
    arrayX = global_values.arrayX
    arrayY = global_values.arrayY
    resultX = arrayX[0]
    resultY = arrayY[0]


    for xx in arrayX:
        for yy in arrayY:
            if xx[0] < x_target and xx[1] > x_target:
                resultX = xx
            if yy[0] < y_target and yy[1] > y_target:
                resultY = yy


    # print(resultX)
    # print(resultY)
    xml = open('qtable.xml', "r")
    org_xml = xml.read()
    dict_xml = xmltodict.parse(org_xml, process_namespaces=True)
    d = dict_xml['root']

    vfh_action_reward=float(d[str(resultX).replace("[","l").replace("]","r").replace(",","c").replace(" ","s")][str(resultY).replace("[","l").replace("]","r").replace(",","c").replace(" ","s")]["vfh"])
    bug_left_action_reward=float(d[str(resultX).replace("[","l").replace("]","r").replace(",","c").replace(" ","s")][str(resultY).replace("[","l").replace("]","r").replace(",","c").replace(" ","s")]["bug_left"])
    bug_right_action_reward=float(d[str(resultX).replace("[","l").replace("]","r").replace(",","c").replace(" ","s")][str(resultY).replace("[","l").replace("]","r").replace(",","c").replace(" ","s")]["bug_right"])
    max=float(max(bug_left_action_reward,bug_right_action_reward, vfh_action_reward))
    randomMove=False

    if (numpy.random.rand() < global_values.epsilon):
        print(random.choice(["vfh","bug_left","bug_right"]))
        randomMove=True

    if not randomMove:
        if max==vfh_action_reward:
            print("vfh")
        elif max==bug_left_action_reward:
            print("bug_left")
        elif max==bug_right_action_reward:
            print("bug_right")