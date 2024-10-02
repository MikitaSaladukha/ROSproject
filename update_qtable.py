import global_values
import sys
import xmltodict

def getQtableXY(x_coordinate,y_coordinate):
    global_values.set_arrays_borders()
    arrayX = global_values.arrayX
    arrayY = global_values.arrayY
    resultX = arrayX[0]
    resultY = arrayY[0]

    for xx in arrayX:
        for yy in arrayY:
            if xx[0] < x_coordinate and xx[1] > x_coordinate:
                resultX = xx
            if yy[0] < y_coordinate and yy[1] > y_coordinate:
                resultY = yy
    return [resultX,resultY]


if __name__ == '__main__':
    x_current = float(sys.argv[1])
    y_current = float(sys.argv[2])
    x_previous = float(sys.argv[3])
    y_previous = float(sys.argv[4])
    action_previous= sys.argv[5]


    xyPrevious = getQtableXY(x_previous,y_previous)
    xyCurrent= getQtableXY(x_current,y_current)

    xml = open('qtable.xml', "r")
    org_xml = xml.read()
    dict_xml = xmltodict.parse(org_xml, process_namespaces=True)
    d=dict_xml['root']



    vfh_action_reward=float(d[str(xyCurrent[0]).replace("[","l").replace("]","r").replace(",","c").replace(" ","s")][str(xyCurrent[1]).replace("[","l").replace("]","r").replace(",","c").replace(" ","s")]["vfh"])
    bug_left_action_reward=float(d[str(xyCurrent[0]).replace("[","l").replace("]","r").replace(",","c").replace(" ","s")][str(xyCurrent[1]).replace("[","l").replace("]","r").replace(",","c").replace(" ","s")]["bug_left"])
    bug_right_action_reward=float(d[str(xyCurrent[0]).replace("[","l").replace("]","r").replace(",","c").replace(" ","s")][str(xyCurrent[1]).replace("[","l").replace("]","r").replace(",","c").replace(" ","s")]["bug_right"])
    max_reward_from_current=float(max(bug_left_action_reward,bug_right_action_reward, vfh_action_reward))

    if abs(x_current-global_values.Xtarget) < 0.25 and abs(y_current-global_values.Ytarget) < 0.25:
        reward=100.0
    else:
        reward=global_values.immediate_reward

    temp=float(d[str(xyPrevious[0]).replace("[","l").replace("]","r").replace(",","c").replace(" ","s")][str(xyPrevious[1]).replace("[","l").replace("]","r").replace(",","c").replace(" ","s")][action_previous])

    temp=(1.0 - float(global_values.alpha)) * float(temp)+ float(global_values.alpha) * (float(reward) + float(global_values.gamma) * float(max_reward_from_current))

    d[str(xyPrevious[0]).replace("[","l").replace("]","r").replace(",","c").replace(" ","s")][str(xyPrevious[1]).replace("[","l").replace("]","r").replace(",","c").replace(" ","s")][action_previous]=temp
    global_values.total_episode_reward += float(d[str(xyPrevious[0]).replace("[","l").replace("]","r").replace(",","c").replace(" ","s")][str(xyPrevious[1]).replace("[","l").replace("]","r").replace(",","c").replace(" ","s")][action_previous])

    future_xml = {'root': d}

    out = xmltodict.unparse(future_xml, pretty=True)

    open("qtable.xml", "w").close()
    with open("qtable.xml", 'w') as file:
        file.write(out)


    print("Qtable_updated_successfully")
    print("qtable.xml:[",str(xyPrevious[0]),"][",str(xyPrevious[1]),"], action=",action_previous,"; value=", d[str(xyPrevious[0]).replace("[","l").replace("]","r").replace(",","c").replace(" ","s")][str(xyPrevious[1]).replace("[","l").replace("]","r").replace(",","c").replace(" ","s")][action_previous])