#!/bin/bash
source /opt/ros/humble/setup.bash

xTarget=1.0
yTarget=-1.0
i=$(ros2 topic echo --once /odom)
angle=($(python3 getAngleToTarget.py $i $xTarget $yTarget))
python3 getAngleToTarget.py $i $xTarget $yTarget

python3 getRollingSpeed.py ${angle[-1]} ${angle[-2]}

#<editor-fold desc="Description">
#echo ${angle[-9]}
#echo ${angle[-8]}
#echo "${angle[-7]} ${angle[-6]} ${angle[-5]} ${angle[-4]} ${angle[-3]}"
#echo ${angle[-2]}
#echo ${angle[-1]}
#</editor-fold>

