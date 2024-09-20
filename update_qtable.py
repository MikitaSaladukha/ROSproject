import global_values
import sys
import json

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
    action_previous=sys.argv[5]


    xyPrevious = getQtableXY(x_previous,y_previous)
    xyCurrent= getQtableXY(x_current,y_current)


    # print(resultX)
    # print(resultY)
    with open('qtable.json') as f:
        d = json.load(f)


    vfh_action_reward=d[str(xyCurrent[0])][str(xyCurrent[1])]["vfh"]
    bug_left_action_reward=d[str(xyCurrent[0])][str(xyCurrent[1])]["bug_left"]
    bug_right_action_reward=d[str(xyCurrent[0])][str(xyCurrent[1])]["bug_right"]
    max_reward_from_current=max(bug_left_action_reward,bug_right_action_reward, vfh_action_reward)

    if abs(x_current-global_values.Xtarget) < 0.25 and abs(y_current-global_values.Ytarget) < 0.25:
        reward=100
    else:
        reward=global_values.immediate_reward

    d[str(xyPrevious[0])][str(xyPrevious[1])][action_previous]=(1 - global_values.alpha) * d[str(xyPrevious[0])][str(xyPrevious[1])][action_previous] + global_values.alpha * (reward + global_values.gamma * max_reward_from_current)
    global_values.total_episode_reward += d[str(xyPrevious[0])][str(xyPrevious[1])][action_previous]

    with open('qtable.json', 'w') as f:
        json.dump(d, f, ensure_ascii=False)

    print("Qtable_updated_successfully")
    print("qtable.json:[",str(xyPrevious[0]),"][",str(xyPrevious[1]),"], action=",action_previous,"; value=", d[str(xyPrevious[0])][str(xyPrevious[1])][action_previous])