import sys;
import math;
import numpy;
#copy from getClosestAngleDist.py
if __name__ == '__main__':
    RForCandidate = float(sys.argv[-1])
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
    print(len(candidateSectors))
    for candidate in candidateSectors:
        print(candidate[0])
        print(candidate[1])


