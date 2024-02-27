import sys;
import math;
import numpy;
#copy from getClosestAngleDist.py
if __name__ == '__main__':
    delta = 3.0  #delta for angles while turning
    angle_current = float (sys.argv[-3])
    angle_target = float(sys.argv[-2])
    RForCandidate = float(sys.argv[-1])
    relative_target_angle = round(angle_current - angle_target)
    if relative_target_angle < 0: relative_target_angle = relative_target_angle + 360
    startingI=25
    Start=sys.argv[startingI]
    angle=0
    startedCandidateSector=False
    candidateSectors=[]
    for i in range(startingI, 720+startingI, 2):
        if sys.argv[i]=='.inf' or float(sys.argv[i]) >= RForCandidate:
           if not startedCandidateSector:
               startedCandidateSector = True
               start = angle

        if sys.argv[i]!='.inf' and float(sys.argv[i]) < RForCandidate and startedCandidateSector:
            end = angle-1
            startedCandidateSector = False
            candidateSectors.append([start,end])

        angle = angle + 1
    if startedCandidateSector:
        end = angle
        candidateSectors.append([start,end])
    if candidateSectors[0][0] == 0 and candidateSectors[len(candidateSectors)-1][1] == 360 :
        candidateSectors[0][0] = candidateSectors[len(candidateSectors)-1][0]
        candidateSectors[0][1] = candidateSectors[0][1] + 360
        candidateSectors.pop()

    if candidateSectors[0][0] > 360: candidateSectors[0][0] = candidateSectors[0][0] - 360
    if candidateSectors[0][1] > 360: candidateSectors[0][1] = candidateSectors[0][1] - 360
    if candidateSectors[0][0] > candidateSectors[0][1]:
        temp = candidateSectors[0][1]
        candidateSectors[0][1] = candidateSectors[0][0]
        candidateSectors[0][1] = temp
    #print(len(candidateSectors))
    broadCandidateSectors = []
    for candidate in candidateSectors:
        if (candidate[1]-candidate[0] >= 180 or 2*RForCandidate*RForCandidate*(1-math.cos(math.radians(candidate[1]-candidate[0]))) <= 0.2):
            broadCandidateSectors.append([candidate[0],candidate[1]])

    print(len(broadCandidateSectors))
    for candidate in broadCandidateSectors:
        print(candidate[0])
        print(candidate[1])

    selectedIndex = 0
    turn_target_delta = 360
    if relative_target_angle >= broadCandidateSectors[0][0] and relative_target_angle <= broadCandidateSectors[0][1]:
        turn_target_delta = 0
    elif relative_target_angle < broadCandidateSectors[0][0]:
        turn_target_delta = broadCandidateSectors[0][0]
    elif relative_target_angle > broadCandidateSectors[0][1]:
        temp_turn_target_delta = broadCandidateSectors[0][1] - 360
        if math.fabs(temp_turn_target_delta) < math.fabs(turn_target_delta):
            turn_target_delta = temp_turn_target_delta

    for i in range(0,len(broadCandidateSectors)-1):
        if relative_target_angle >= broadCandidateSectors[i][0] and relative_target_angle <= broadCandidateSectors[i][1]:
            temp_turn_target_delta = 0
        elif relative_target_angle < broadCandidateSectors[i][0]:
            temp_turn_target_delta = broadCandidateSectors[i][0]
        elif relative_target_angle > broadCandidateSectors[i][1]:
            temp_turn_target_delta = broadCandidateSectors[i][1] - 360

        if math.fabs(temp_turn_target_delta) < math.fabs(turn_target_delta):
            turn_target_delta = temp_turn_target_delta
            selectedIndex = i

    if turn_target_delta == 0:
        print(angle_target)
    else:
        print((angle_current+turn_target_delta))
