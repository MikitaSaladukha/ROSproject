#!/bin/bash

function turnToTarget() {
  source /opt/ros/humble/setup.bash
  xTarget=$1
  yTarget=$2
  i=$(ros2 topic echo --once /odom)
  angle=($(python3 getAngleToTarget.py $i $xTarget $yTarget))
  echo ${angle[-9]}
  echo ${angle[-8]}
  echo "${angle[-7]} ${angle[-6]} ${angle[-5]} ${angle[-4]} ${angle[-3]}"
  echo ${angle[-2]}
  echo ${angle[-1]}

  rollingSpeed=($(python3 getRollingSpeed.py ${angle[-1]} ${angle[-2]}))

  speedString=" "${rollingSpeed[0]}" "${rollingSpeed[1]}" "${rollingSpeed[2]}" "${rollingSpeed[3]}" "${rollingSpeed[4]}" "${rollingSpeed[5]}" "${rollingSpeed[6]}" "${rollingSpeed[7]}" "${rollingSpeed[8]}" "${rollingSpeed[9]}" "${rollingSpeed[10]}" "${rollingSpeed[11]}" "${rollingSpeed[12]}
  echo  'RollingSpeed='$speedString
  mycommand='ros2 topic pub --once /cmd_vel geometry_msgs/Twist '$speedString
  eval $mycommand
}
x_target=3.0
y_target=3.0
turnToTarget $x_target $y_target


ros2 topic pub --once /cmd_vel geometry_msgs/Twist '{linear:  {x: 0.0, y: 0.0, z: 0.0}, angular: {x: 0.0,y: 0.0,z: 0.0}}'