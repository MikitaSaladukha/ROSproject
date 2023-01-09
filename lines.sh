#!/bin/bash
source /opt/ros/humble/setup.bash
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
  echo  'RollingSpeed='$speedString' angle1='${angle[-1]}' angle2='${angle[-2]}
  mycommand='ros2 topic pub --once /cmd_vel geometry_msgs/Twist '$speedString
  eval $mycommand
}


function roundToTarget() {
  x_target=$1
  y_target=$2
  angel_target=0
  angle_current=90
  good="false"

  while [ "false" = "$good" ]
  do
    turnToTarget $x_target $y_target
    i=$(ros2 topic echo --once /odom)
    angle=($(python3 getAngleToTarget.py $i $x_target $y_target))
    angel_target=${angle[-1]}
    angle_current=${angle[-2]}
    delta="3.0"
    good=($(python3 compareAngles.py $delta $angel_target $angle_current))
  done
  ros2 topic pub --once /cmd_vel geometry_msgs/Twist '{linear:  {x: 0.0, y: 0.0, z: 0.0}, angular: {x: 0.0,y: 0.0,z: 0.0}}'
}

function moveToTarget() {
  goal="false"
  x_target=$1
  y_target=$2
  while [ "false" = "$goal" ]; do


    roundToTarget $1 $2
    #sleep 4
    ros2 topic pub --once /cmd_vel geometry_msgs/Twist '{linear:  {x: 0.1, y: 0.0, z: 0.0}, angular: {x: 0.0,y: 0.0,z: 0.0}}'
    sleep 6
    ros2 topic pub --once /cmd_vel geometry_msgs/Twist '{linear:  {x: 0.0, y: 0.0, z: 0.0}, angular: {x: 0.0,y: 0.0,z: 0.0}}'
    i=$(ros2 topic echo --once /odom)
    XYcurrent=($(python3 getAngleToTarget.py $i $x_target $y_target))
    Xcurr=${XYcurrent[0]};
    Ycurr=${XYcurrent[1]};
    delta="0.2"
    echo $Xcurr
    echo $Ycurr
    echo $delta
    #echo ${XYcurrent[0]}
    #echo ${XYcurrent[1]}
    good1=($(python3 isEqualFloat.py $delta $x_target $Xcurr))
    good2=($(python3 isEqualFloat.py $delta $y_target $Ycurr))
    echo $good1
    echo $good2
    # shellcheck disable=SC1073
    if [ $good1 = "false" -o $good2 = "false" ]
    then
      goal="false"
    else
      goal="true"
    fi

  done
}


k="not_set";
b="not_set";
function set_k_b() {
  i=$(ros2 topic echo --once /odom)
  XYcurrent=($(python3 getCurrXY.py $i))
  Xcurr=${XYcurrent[0]};
  Ycurr=${XYcurrent[1]};
  x_target=$1;
  y_target=$2;
  kb=($(python3 get_k_b_fromX1Y1X2Y2.py $x_target $y_target $Xcurr $Ycurr))
  k=${kb[0]};
  b=${kb[1]};

}
#roundToTarget $x $y
#x_target=$x
#y_target=$y
##ros2 topic pub --once /cmd_vel geometry_msgs/Twist '{linear:  {x: 0.0, y: 0.0, z: 0.0}, angular: {x: 0.0,y: 0.0,z: 0.0}}'
#i=$(ros2 topic echo --once /odom)
#XYcurrent=($(python3 getAngleToTarget.py $i $x_target $y_target))
#echo ${XYcurrent[0]}
#echo ${XYcurrent[1]}
#roundToTarget "1" "-2"
#moveToTarget "3" "3"
set_k_b "0.1" "0.2"
echo "k="$k
echo "b="$b

online="not_set";
function checkOnLine() {
  i=$(ros2 topic echo --once /odom)

  XYcurrent=($(python3 getCurrXY.py $i))
  Xcurr=${XYcurrent[0]};
  Ycurr=${XYcurrent[1]};
  online=($(python3 isOnLineXYkb.py $Xcurr $Ycurr $k $b))
}

function moveToTargetWithStop() {
  goal="false"
  near="false"
  x_target=$1
  y_target=$2
  while [ "false" = "$goal" ]; do
    roundToTarget $1 $2
    #sleep 4
    for j in {1..6}; do
      ros2 topic pub --once /cmd_vel geometry_msgs/Twist '{linear:  {x: 0.1, y: 0.0, z: 0.0}, angular: {x: 0.0,y: 0.0,z: 0.0}}'
      i=$(ros2 topic echo --once /scan -f)
      close=($(python3 getClosestAngleDist.py $i "0" "0.3c"))
      N=${close[-1]}
      if [ $N != "0" ]
        then
          near="true"
          ros2 topic pub --once /cmd_vel geometry_msgs/Twist '{linear:  {x: 0.0, y: 0.0, z: 0.0}, angular: {x: 0.0,y: 0.0,z: 0.0}}'
        break
      fi
      sleep 1
    done
    echo "near="$near
    if [ $near = "true" ]
      then
        break
    fi
    ros2 topic pub --once /cmd_vel geometry_msgs/Twist '{linear:  {x: 0.0, y: 0.0, z: 0.0}, angular: {x: 0.0,y: 0.0,z: 0.0}}'
    i=$(ros2 topic echo --once /odom)
    XYcurrent=($(python3 getAngleToTarget.py $i $x_target $y_target))
    Xcurr=${XYcurrent[0]};
    Ycurr=${XYcurrent[1]};
    delta="0.2"
    echo $Xcurr
    echo $Ycurr
    echo $delta
    #echo ${XYcurrent[0]}
    #echo ${XYcurrent[1]}
    good1=($(python3 isEqualFloat.py $delta $x_target $Xcurr))
    good2=($(python3 isEqualFloat.py $delta $y_target $Ycurr))
    echo $good1
    echo $good2
    # shellcheck disable=SC1073
    if [ $good1 = "false" -o $good2 = "false" ]
    then
      goal="false"
    else
      goal="true"
    fi

  done
}


targetX="1"
targetY="0.2"
#checkOnLine
#echo $online
set_k_b $targetX $targetY
moveToTargetWithStop $targetX $targetY