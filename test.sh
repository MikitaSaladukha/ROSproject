#!/bin/bash
source /opt/ros/humble/setup.bash


#i=$(ros2 topic echo --once /scan -f)
i=$(ros2 topic echo --once /odom)
echo $i
XYcurrent=($(python3 getCurrXY.py $i))
Xcurr=${XYcurrent[0]};
Ycurr=${XYcurrent[1]};
echo $Xcurr
echo $Ycurr


#i=$(ros2 topic echo --once /scan -f)
#python3 getClosestAngleDist.py $i "1.96"



#xTarget=1.0
#yTarget=-1.0
#i=$(ros2 topic echo --once /odom)
#angle=($(python3 getAngleToTarget.py $i $xTarget $yTarget))
#python3 getAngleToTarget.py $i $xTarget $yTarget

#python3 getRollingSpeed.py ${angle[-1]} ${angle[-2]}
#==============================================
#<editor-fold desc="Description">
#echo ${angle[-9]}
#echo ${angle[-8]}
#echo "${angle[-7]} ${angle[-6]} ${angle[-5]} ${angle[-4]} ${angle[-3]}"
#echo ${angle[-2]}
#echo ${angle[-1]}
#</editor-fold>

