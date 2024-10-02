import global_values
import sys
import xmltodict
import random_q_table

if __name__ == '__main__':
    # x_target = float(sys.argv[0])
    # y_target = float(sys.argv[1])
    # action_target = sys.argv[2]
    # random_q_table.generate_random_q_table() # delete in final version

    x_target = 2.3
    y_target = 4.4
    action_target = "vfh"

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

    result = d[str(resultX).replace("[","l").replace("]","r").replace(",","c").replace(" ","s")][str(resultY).replace("[","l").replace("]","r").replace(",","c").replace(" ","s")][action_target]
    print("reward=",result)
