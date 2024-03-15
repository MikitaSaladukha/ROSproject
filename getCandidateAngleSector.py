import sys;
import math;
import numpy;
#copy from getClosestAngleDist.py

 #   i=  selectedIndex = 0
 #   initial_temp_turn_target_delta =  turn_target_delta = 360
 # relative_target_angle = round(angle_current - angle_target)
 # if relative_target_angle < 0: relative_target_angle = relative_target_angle + 360
def getTempTurnTargetDeltaAndRangeDistance(broadCandidateSectors,i,relative_target_angle):
    lowerAngleBoundary = min(broadCandidateSectors[i][0],broadCandidateSectors[i][1])
    upperAngleBoundary = max(broadCandidateSectors[i][0], broadCandidateSectors[i][1])
    if lowerAngleBoundary == broadCandidateSectors[i][0]:
        lowerAngleBoundaryRange = broadCandidateSectors[i][2]
        upperAngleBoundaryRange = broadCandidateSectors[i][3]
    else: ##  lowerAngleBoundary == broadCandidateSectors[i][1]:
        lowerAngleBoundaryRange = broadCandidateSectors[i][3]
        upperAngleBoundaryRange = broadCandidateSectors[i][2]

    if relative_target_angle >= lowerAngleBoundary and relative_target_angle <= upperAngleBoundary:
        temp_turn_target_delta = 0 #0 значит, что чтобы двигаться к цели, движемся прямо к цели, не изменяя прямую линию до цели
        rangeDistance = RForCandidate
    elif relative_target_angle < lowerAngleBoundary:
        temp_turn_target_delta = lowerAngleBoundary
        rangeDistance = lowerAngleBoundaryRange
    elif relative_target_angle > upperAngleBoundary:
        temp_turn_target_delta = upperAngleBoundary - 360
        rangeDistance = upperAngleBoundaryRange
    return [temp_turn_target_delta,rangeDistance]

if __name__ == '__main__':
    delta = 3.0  #delta for angles while turning
    angle_current = float (sys.argv[-3])
    angle_target = float(sys.argv[-2])
    RForCandidate = float(sys.argv[-1]) ## дальность до препятствия, или на какой дальности производится оценка возможных свободных секторов
    # сделать цикл, увеличивая RForCandidate до 3.6 либо
    # пока массив broadCandidateSectors не станет пустым.
    # В последнем случае выбрать значение broadCandidateSectors из предыдущей итерации цикла
    relative_target_angle = round(angle_current - angle_target) # инверсия т.к. угол к цели отсчитывается против часовой стрелки, а углы вокруг робота - по часовой
    if relative_target_angle < 0: relative_target_angle = relative_target_angle + 360
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
                       startObstacleDistance = 3.6
                   elif sys.argv[i] == '.inf':
                       startObstacleDistance = 3.7
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
    if candidateSectors[0][0] == 0 and candidateSectors[len(candidateSectors)-1][1] == 360 :
        candidateSectors[0][0] = candidateSectors[len(candidateSectors)-1][0] #
        candidateSectors[0][1] = candidateSectors[0][1] #

        candidateSectors[0][3] = candidateSectors[0][3] #
        candidateSectors[0][2] = candidateSectors[len(candidateSectors)-1][2]

        candidateSectors.pop()

    broadCandidateSectors = []
    for candidate in candidateSectors:
        if candidate[1] > candidate[0]:
            if (candidate[1]-candidate[0] >= 180 or 2*RForCandidate*RForCandidate*(1-math.cos(math.radians(math.fabs(candidate[1]-candidate[0])))) >= 0.3): ## 0.3 - широта робота
                broadCandidateSectors.append([candidate[0],candidate[1],candidate[2],candidate[3]])
        if candidate[1] < candidate[0]:
            if (candidate[1] - candidate[0] >= -180 or 2 * RForCandidate * RForCandidate * (1 - math.cos(math.radians(math.fabs(candidate[1] - candidate[0])))) >= 0.3):
                broadCandidateSectors.append([candidate[0], candidate[1], candidate[2], candidate[3]])



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
    # if broadCandidateSectors[0][0] < broadCandidateSectors[0][1]:
    #     if relative_target_angle >= broadCandidateSectors[0][0] and relative_target_angle <= broadCandidateSectors[0][1]:
    #         turn_target_delta = 0.0
    #         rangeDistance = 3.5
    #     elif relative_target_angle < broadCandidateSectors[0][0]:
    #         turn_target_delta = broadCandidateSectors[0][0]
    #         rangeDistance = broadCandidateSectors[0][2]
    #     elif relative_target_angle > broadCandidateSectors[0][1]:
    #         temp_turn_target_delta = broadCandidateSectors[0][1] - 360
    #         if math.fabs(temp_turn_target_delta) < math.fabs(turn_target_delta):
    #             turn_target_delta = temp_turn_target_delta
    #             rangeDistance = broadCandidateSectors[0][3]
    # if broadCandidateSectors[0][0] > broadCandidateSectors[0][1]:
    #     if relative_target_angle <= broadCandidateSectors[0][1] or relative_target_angle >= broadCandidateSectors[0][0]:
    #         turn_target_delta = 0.0
    #         rangeDistance = 3.5
    #     elif relative_target_angle <= broadCandidateSectors[0][0] :
    #         if broadCandidateSectors[0][0] > 270:
    #             turn_target_delta = broadCandidateSectors[0][0] - 360
    #             rangeDistance = broadCandidateSectors[0][2]
    #         else:
    #             turn_target_delta = broadCandidateSectors[0][0]
    #             rangeDistance = broadCandidateSectors[0][2]
    #     elif relative_target_angle > broadCandidateSectors[0][1]:
    #         if broadCandidateSectors[0][1] > 270:
    #             temp_turn_target_delta = broadCandidateSectors[0][1] - 360
    #         else:
    #             temp_turn_target_delta = broadCandidateSectors[0][1]
    #         if math.fabs(temp_turn_target_delta) < math.fabs(turn_target_delta):
    #             turn_target_delta = temp_turn_target_delta
    #             rangeDistance = broadCandidateSectors[0][3]

    for i in range(0,len(broadCandidateSectors)-1):
############################################################
        twoValues2 = getTempTurnTargetDeltaAndRangeDistance(broadCandidateSectors,i,relative_target_angle)
        temp_turn_target_delta = twoValues2[0]
        rangeDistance2 = twoValues2[1]
##########################################################
        if math.fabs(temp_turn_target_delta) < math.fabs(turn_target_delta):
            turn_target_delta = temp_turn_target_delta
            selectedIndex = i
            rangeDistance = rangeDistance2

    if math.fabs(turn_target_delta) <= 0.00000000001:
        print(angle_target)
    else:
        print((angle_current+turn_target_delta))
