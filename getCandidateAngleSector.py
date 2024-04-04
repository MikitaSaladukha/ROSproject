import sys;
import math;
import numpy;
#copy from getClosestAngleDist.py

 #   i=  selectedIndex = 0
 #   initial_temp_turn_target_delta =  turn_target_delta = 360
 # relative_target_angle = round(angle_current - angle_target)
 # if relative_target_angle < 0: relative_target_angle = relative_target_angle + 360


def getTempTurnTargetDeltaAndRangeDistance(broadCandidateSectors,i,relative_target_angle):

    directionOfSector = 0 # stright forward, -1 less, +1 more
    lowerAngleBoundary = min(broadCandidateSectors[i][0],broadCandidateSectors[i][1])
    upperAngleBoundary = max(broadCandidateSectors[i][0], broadCandidateSectors[i][1])
    # сделать запас в 5 градусов - чтобы робот не столкнулся краем с препрястввия - возможно, в конце этого всего кода
    angle_zapas_for_robot = 5

    #if relative_target_angle < 0 : print ("minus_detected:_",relative_target_angle)
    #if True:#relative_target_angle >= 0:
    if not (i == 0 and inverse_obsltacle):
        if lowerAngleBoundary == broadCandidateSectors[i][0]:
            lowerAngleBoundaryRange = broadCandidateSectors[i][2]
            upperAngleBoundaryRange = broadCandidateSectors[i][3]
        else: ##  lowerAngleBoundary == broadCandidateSectors[i][1]:
            lowerAngleBoundaryRange = broadCandidateSectors[i][3]
            upperAngleBoundaryRange = broadCandidateSectors[i][2]

        if relative_target_angle >= lowerAngleBoundary+angle_zapas_for_robot and relative_target_angle <= upperAngleBoundary-angle_zapas_for_robot:
            temp_turn_target_delta = relative_target_angle #relative_target_angle значит, что чтобы двигаться к цели, движемся прямо к цели, не изменяя прямую линию до цели
            rangeDistance = RForCandidate
            directionOfSector = 0
        elif relative_target_angle < lowerAngleBoundary+angle_zapas_for_robot:
            if lowerAngleBoundary > 180:
                temp_turn_target_delta = lowerAngleBoundary - 360
                directionOfSector = 1
            else:
                temp_turn_target_delta = lowerAngleBoundary
                directionOfSector = 1
            rangeDistance = lowerAngleBoundaryRange
            directionOfSector = 1
            # print("here,_directionOfSector=", directionOfSector)
        elif relative_target_angle > upperAngleBoundary-angle_zapas_for_robot:
            if upperAngleBoundary > 180:
                temp_turn_target_delta = upperAngleBoundary - 360
                directionOfSector = -1
            else:
                temp_turn_target_delta = upperAngleBoundary
                directionOfSector = 1
            rangeDistance = upperAngleBoundaryRange
            directionOfSector = -1
            # print("here,_directionOfSector2=",directionOfSector)
        return [temp_turn_target_delta,rangeDistance,directionOfSector]
    else:
        if lowerAngleBoundary == broadCandidateSectors[i][0]:
            lowerAngleBoundaryRange = broadCandidateSectors[i][2]
            upperAngleBoundaryRange = broadCandidateSectors[i][3]
        else: ##  lowerAngleBoundary == broadCandidateSectors[i][1]:
            lowerAngleBoundaryRange = broadCandidateSectors[i][3]
            upperAngleBoundaryRange = broadCandidateSectors[i][2]
        if relative_target_angle <= lowerAngleBoundary-angle_zapas_for_robot or relative_target_angle >= upperAngleBoundary+angle_zapas_for_robot:
            temp_turn_target_delta = relative_target_angle  # relative_target_angle значит, что чтобы двигаться к цели, движемся прямо к цели, не изменяя прямую линию до цели
            rangeDistance = RForCandidate
            directionOfSector = 0
        elif relative_target_angle > lowerAngleBoundary-angle_zapas_for_robot:
            if lowerAngleBoundary > 180:
                temp_turn_target_delta = lowerAngleBoundary - 360
                directionOfSector = -1
            else:
                temp_turn_target_delta = lowerAngleBoundary
                directionOfSector = 1

            # temp_turn_target_delta = lowerAngleBoundary
            directionOfSector = -1
            rangeDistance = lowerAngleBoundaryRange
        elif relative_target_angle < upperAngleBoundary+angle_zapas_for_robot:
            if upperAngleBoundary > 180:
                temp_turn_target_delta = upperAngleBoundary - 360
                directionOfSector = -1
            else:
                temp_turn_target_delta = upperAngleBoundary
                directionOfSector = 1
            rangeDistance = upperAngleBoundaryRange
            # temp_turn_target_delta = upperAngleBoundary - 360
            directionOfSector = 1
        return [temp_turn_target_delta, rangeDistance, directionOfSector]


if __name__ == '__main__':
    delta = 3.0  #delta for angles while turning
    inverse_obsltacle = False
    angle_current = float (sys.argv[-3])
    angle_target = float(sys.argv[-2])
    RForCandidate = float(sys.argv[-1]) ## дальность до препятствия, или на какой дальности производится оценка возможных свободных секторов
    # сделать цикл, увеличивая RForCandidate до 3.6 либо
    # пока массив broadCandidateSectors не станет пустым.
    # В последнем случае выбрать значение broadCandidateSectors из предыдущей итерации цикла

    # проверить, чтобы relative_target_angle вычислялся корректно
    # для положительных углов:
    relative_target_angle = round (angle_target- angle_current)
    broadCandidateSectors = []
    if relative_target_angle < 0: relative_target_angle = relative_target_angle + 360
    if relative_target_angle > 360: relative_target_angle = relative_target_angle - 360
    #check_with_minus_relative_target_angle = relative_target_angle
    ##if relative_target_angle > 270:
    check_with_minus_relative_target_angle = relative_target_angle - 360 # было >270

    minus_relative_target_angle360 = 360 + relative_target_angle# relative_target_angle-360

    # if relative_target_angle > 360: relative_target_angle = relative_target_angle - 360
    while True: #отсчет углов идет против часовой стрелки
        startingI=25
        Start=sys.argv[startingI]
        angle=0
        startedCandidateSector=False
        candidateSectors=[]
        for i in range(startingI, 720+startingI, 2):
            if angle>90 and angle<270:
                angle = angle + 1
                continue
            if sys.argv[i]=='.inf' or float(sys.argv[i]) >= RForCandidate:
               if not startedCandidateSector:
                   startedCandidateSector = True
                   start = angle
                   try:
                       startObstacleDistance = float(sys.argv[i - 2])
                   except ValueError:
                       if sys.argv[i-2]=='.inf':
                           startObstacleDistance = 3.5
                       elif sys.argv[i] == '.inf':
                           startObstacleDistance = 3.5
                       else:
                           startObstacleDistance = float(sys.argv[i])


            if sys.argv[i]!='.inf' and float(sys.argv[i]) < RForCandidate and startedCandidateSector:
                end = angle-1
                endObstacleDistance = float(sys.argv[i])
                startedCandidateSector = False
                candidateSectors.append([start,end,startObstacleDistance,endObstacleDistance])

            angle = angle + 1
        if startedCandidateSector:
            end = angle
            candidateSectors.append([start,end,startObstacleDistance,3.5])
        if candidateSectors[0][0] == 0 and candidateSectors[len(candidateSectors)-1][1] == 360 and len(candidateSectors)>1:
            candidateSectors[0][0] = candidateSectors[len(candidateSectors)-1][0] #
            candidateSectors[0][1] = candidateSectors[0][1] #

            candidateSectors[0][3] = candidateSectors[0][3] #
            candidateSectors[0][2] = candidateSectors[len(candidateSectors)-1][2]
            inverse_obsltacle = True
            candidateSectors.pop()

        broadCandidateSectorsPrevious = broadCandidateSectors
        broadCandidateSectors = []
        for candidate in candidateSectors:
            if candidate[1] > candidate[0]:
                if (candidate[1]-candidate[0] >= 180 or 2*RForCandidate*RForCandidate*(1-math.cos(math.radians(math.fabs(candidate[1]-candidate[0])))) >= 0.3): ## 0.3 - широта робота
                    broadCandidateSectors.append([candidate[0],candidate[1],candidate[2],candidate[3]])
            if candidate[1] < candidate[0]:
                if (candidate[1] - candidate[0] >= -180 or 2 * RForCandidate * RForCandidate * (1 - math.cos(math.radians(math.fabs(candidate[1] - candidate[0])))) >= 0.3):
                    broadCandidateSectors.append([candidate[0], candidate[1], candidate[2], candidate[3]])
        if len(broadCandidateSectors) == 0:
            broadCandidateSectors = broadCandidateSectorsPrevious
            RForCandidate = RForCandidate - 0.2
            break
        RForCandidate = RForCandidate + 0.2
        if RForCandidate >= 3.5:
            RForCandidate = RForCandidate - 0.2
            break


    print(len(broadCandidateSectors))
    for candidate in broadCandidateSectors:
        print(candidate[0])
        print(candidate[1])
        print(candidate[2])
        print(candidate[3])

    selectedIndex = 0
    turn_target_delta = 360
    twoValues = getTempTurnTargetDeltaAndRangeDistance(broadCandidateSectors, selectedIndex,relative_target_angle)
    turn_target_delta = twoValues[0]
    rangeDistance = twoValues[1]
    directionOfSector = twoValues[2]

    twoValues2 = getTempTurnTargetDeltaAndRangeDistance(broadCandidateSectors, selectedIndex,check_with_minus_relative_target_angle)
    temp_turn_target_delta = twoValues2[0]
    rangeDistance2 = twoValues2[1]
    temp_directionOfSector = twoValues2[2]
    # print("direction_of_sector!=",temp_directionOfSector)
    if math.fabs(temp_turn_target_delta - check_with_minus_relative_target_angle) <= math.fabs(turn_target_delta - check_with_minus_relative_target_angle):
        turn_target_delta = temp_turn_target_delta
        rangeDistance = rangeDistance2
        directionOfSector = temp_directionOfSector

###????????????????????????????????
    twoValues2 = getTempTurnTargetDeltaAndRangeDistance(broadCandidateSectors, selectedIndex,minus_relative_target_angle360)
    temp_turn_target_delta = twoValues2[0]
    rangeDistance2 = twoValues2[1]
    temp_directionOfSector = twoValues2[2]
    ##temp_turn_target_delta360 = temp_turn_target_delta + 360
    # print("direction_of_sector!=",temp_directionOfSector)
    if math.fabs(temp_turn_target_delta+360 - minus_relative_target_angle360) <= math.fabs(turn_target_delta+360 - minus_relative_target_angle360):
        turn_target_delta = temp_turn_target_delta
        rangeDistance = rangeDistance2
        directionOfSector = temp_directionOfSector

    for i in range(1,len(broadCandidateSectors)):

        twoValues2 = getTempTurnTargetDeltaAndRangeDistance(broadCandidateSectors,i,check_with_minus_relative_target_angle)
        temp_turn_target_delta = twoValues2[0]
        rangeDistance2 = twoValues2[1]
        temp_directionOfSector = twoValues2[2]
        if math.fabs(temp_turn_target_delta - check_with_minus_relative_target_angle) < math.fabs(turn_target_delta - check_with_minus_relative_target_angle):
            turn_target_delta = temp_turn_target_delta
            selectedIndex = i
            rangeDistance = rangeDistance2
            directionOfSector = temp_directionOfSector
##############????????????????????????????
        twoValues2 = getTempTurnTargetDeltaAndRangeDistance(broadCandidateSectors, i,minus_relative_target_angle360)
        temp_turn_target_delta = twoValues2[0]
        rangeDistance2 = twoValues2[1]
        temp_directionOfSector = twoValues2[2]
        if math.fabs(temp_turn_target_delta + 360 - minus_relative_target_angle360) <= math.fabs(turn_target_delta + 360 - minus_relative_target_angle360):
            turn_target_delta = temp_turn_target_delta
            rangeDistance = rangeDistance2
            directionOfSector = temp_directionOfSector
            selectedIndex = i

        twoValues2 = getTempTurnTargetDeltaAndRangeDistance(broadCandidateSectors,i,relative_target_angle)
        temp_turn_target_delta = twoValues2[0]
        rangeDistance2 = twoValues2[1]
        temp_directionOfSector = twoValues2[2]
        if math.fabs(temp_turn_target_delta - check_with_minus_relative_target_angle) < math.fabs(turn_target_delta - check_with_minus_relative_target_angle):
            turn_target_delta = temp_turn_target_delta
            selectedIndex = i
            rangeDistance = rangeDistance2
            directionOfSector = temp_directionOfSector

    target=0
    if math.fabs(turn_target_delta - relative_target_angle) <= 0.00000000001:
        target = angle_target ## проверить сравнить углы
    else:
        target = angle_current + turn_target_delta+ directionOfSector*6# + 7


    print(target)

    RForCandidate = RForCandidate - 0.4
    print(directionOfSector)
    print(turn_target_delta)
    print(RForCandidate)
    print(relative_target_angle)
    print(check_with_minus_relative_target_angle)
    print(minus_relative_target_angle360)
    #print(check_with_360_relative_target_angle2)