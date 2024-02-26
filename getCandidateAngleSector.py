import sys;
import math;
import numpy;
#copy from getClosestAngleDist.py
if __name__ == '__main__':
    angle_current = float (sys.argv[-3])
    angle_target = float(sys.argv[-2])
    RForCandidate = float(sys.argv[-1])
    relative_target_angle = round(angle_target - angle_current)
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
    #print(len(candidateSectors))
    broadCandidateSectors = []
    for candidate in candidateSectors:
        if (candidate[1]-candidate[0] >= 180 or 2*RForCandidate*RForCandidate*(1-math.cos(math.radians(candidate[1]-candidate[0]))) <= 0.2):
            broadCandidateSectors.append([candidate[0],candidate[1]])

    print(len(broadCandidateSectors))
    for candidate in broadCandidateSectors:
        print(candidate[0])
        print(candidate[1])



