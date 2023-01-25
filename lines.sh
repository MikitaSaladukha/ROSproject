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
goal="false"
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
distanceL="not_set"
function set_distanceL() {
  i=$(ros2 topic echo --once /odom)
  XYcurrent=($(python3 getCurrXY.py $i))
  Xcurr=${XYcurrent[0]};
  Ycurr=${XYcurrent[1]};
  x_target=$1;
  y_target=$2;
  distanceL=($(python3 getDistance.py $x_target $y_target $Xcurr $Ycurr))
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

function checkOnLine() {
  i=$(ros2 topic echo --once /odom)

  XYcurrent=($(python3 getCurrXY.py $i))
  Xcurr=${XYcurrent[0]};
  Ycurr=${XYcurrent[1]};
  online=($(python3 isOnLineXYkb.py $Xcurr $Ycurr $k $b))
}
side="none"
closeDistance="0.4"
function moveToTargetWithStop() {
  goal="false"
  near="false"
  x_target=$1
  y_target=$2
  while [ "false" = "$goal" ]; do
    roundToTarget $1 $2

    i=$(ros2 topic echo --once /scan -f)
    close=($(python3 getClosestAngleDist.py $i $closeDistance))
    side=${close[-1]}
    angle=${close[-2]}
    echo "close1="${close[-3]}
    echo "side="$side
    echo "angle="$angle
    echo "closest distance="${close[-4]}
    if [ $side != "none" ]
      then
        near="true"
        ros2 topic pub --once /cmd_vel geometry_msgs/Twist '{linear:  {x: 0.0, y: 0.0, z: 0.0}, angular: {x: 0.0,y: 0.0,z: 0.0}}'
        break
    fi
    ros2 topic pub --once /cmd_vel geometry_msgs/Twist '{linear:  {x: 0.1, y: 0.0, z: 0.0}, angular: {x: 0.0,y: 0.0,z: 0.0}}'
    #sleep 4

    echo "near="$near" side="$side" closest angle="$angle
    if [ $near = "true" ]
      then
        ros2 topic pub --once /cmd_vel geometry_msgs/Twist '{linear:  {x: 0.0, y: 0.0, z: 0.0}, angular: {x: 0.0,y: 0.0,z: 0.0}}'
        break
    fi

    i=$(ros2 topic echo --once /scan -f)
    close=($(python3 getClosestAngleDist.py $i $closeDistance))
    side=${close[-1]}
    angle=${close[-2]}
    echo "close4="${close[-3]}
    echo "side="$side
    echo "angle="$angle
    echo "closest distance="${close[-4]}
    if [ $side != "none" ]
      then
        near="true"
        ros2 topic pub --once /cmd_vel geometry_msgs/Twist '{linear:  {x: 0.0, y: 0.0, z: 0.0}, angular: {x: 0.0,y: 0.0,z: 0.0}}'
        break
    fi


    echo "check GOAL"
    i=$(ros2 topic echo --once /odom)
    XYcurrent=($(python3 getAngleToTarget.py $i $x_target $y_target))
    Xcurr=${XYcurrent[0]};
    Ycurr=${XYcurrent[1]};
    delta="0.2"
    good1=($(python3 isEqualFloat.py $delta $x_target $Xcurr))
    good2=($(python3 isEqualFloat.py $delta $y_target $Ycurr))
    # shellcheck disable=SC1073
    if [ $good1 = "false" -o $good2 = "false" ]
    then
      goal="false"
    else
      echo "goal REACHED"
      ros2 topic pub --once /cmd_vel geometry_msgs/Twist '{linear:  {x: 0.0, y: 0.0, z: 0.0}, angular: {x: 0.0,y: 0.0,z: 0.0}}'
      goal="true"
      break
    fi
    echo "goal check DONE"

    i=$(ros2 topic echo --once /scan -f)
    close=($(python3 getClosestAngleDist.py $i $closeDistance))
    side=${close[-1]}
    angle=${close[-2]}
    echo "close5="${close[-3]}
    echo "side="$side
    echo "angle="$angle
    echo "closest distance="${close[-4]}
    if [ $side != "none" ]
      then
        near="true"
        ros2 topic pub --once /cmd_vel geometry_msgs/Twist '{linear:  {x: 0.0, y: 0.0, z: 0.0}, angular: {x: 0.0,y: 0.0,z: 0.0}}'
        break
    fi


    echo "check GOAL"
    i=$(ros2 topic echo --once /odom)
    XYcurrent=($(python3 getAngleToTarget.py $i $x_target $y_target))
    Xcurr=${XYcurrent[0]};
    Ycurr=${XYcurrent[1]};
    delta="0.2"
    good1=($(python3 isEqualFloat.py $delta $x_target $Xcurr))
    good2=($(python3 isEqualFloat.py $delta $y_target $Ycurr))
    # shellcheck disable=SC1073
    if [ $good1 = "false" -o $good2 = "false" ]
    then
      goal="false"
    else
      echo "goal REACHED"
      ros2 topic pub --once /cmd_vel geometry_msgs/Twist '{linear:  {x: 0.0, y: 0.0, z: 0.0}, angular: {x: 0.0,y: 0.0,z: 0.0}}'
      goal="true"
      break
    fi
    echo "goal check DONE"

  done

}
function rollingForOrtogonal() {
  command="rolling"
  side=$1
  while [ "good" != "$command" ]; do
    i=$(ros2 topic echo --once /scan -f)
    command1=($(python3 rollingForOrtogonal.py $i $side))
    #echo "command1="$command1
    command=${command1[-1]}
    echo "command="$command
    echo "angle="${command1[0]}
    #sleep 4
    if [ "$command" = "good" ]
      then
        ros2 topic pub --once /cmd_vel geometry_msgs/Twist '{linear:  {x: 0.0, y: 0.0, z: 0.0}, angular: {x: 0.0,y: 0.0,z: 0.0}}'
    fi
    if [ "$command" = "round_plus" ]
      then
        ros2 topic pub --once /cmd_vel geometry_msgs/Twist '{linear:  {x: 0.0, y: 0.0, z: 0.0}, angular: {x: 0.0,y: 0.0,z: 0.01}}'
    fi
        if [ "$command" = "round_minus" ]
      then
        ros2 topic pub --once /cmd_vel geometry_msgs/Twist '{linear:  {x: 0.0, y: 0.0, z: 0.0}, angular: {x: 0.0,y: 0.0,z: -0.01}}'

    fi
  done

}
moving="moving"
function movingFront() {
  moving="moving"
  ros2 topic pub --once /cmd_vel geometry_msgs/Twist '{linear:  {x: 0.1, y: 0.0, z: 0.0}, angular: {x: 0.0,y: 0.0,z: 0.0}}'
  #sleep 2
  while [ "moving" = "$moving" ]; do
    ros2 topic pub --once /cmd_vel geometry_msgs/Twist '{linear:  {x: 0.05, y: 0.0, z: 0.0}, angular: {x: 0.0,y: 0.0,z: 0.0}}'
    i=$(ros2 topic echo --once /scan -f)
    moving=($(python3 movingFront.py $i $side "0.2" "0.27"))
    checkOnLine
    if [ "$online" = "True" ]
      then
        moving="online"
    fi
    echo "moving="$moving
  done
  ros2 topic pub --once /cmd_vel geometry_msgs/Twist '{linear:  {x: 0.0, y: 0.0, z: 0.0}, angular: {x: 0.0,y: 0.0,z: 0.0}}'
}

function turn90() {
  side=$1
  i=$(ros2 topic echo --once /odom)
  angle=($(python3 getAngleToTarget2.py $i $side))
  angel_target=${angle[-1]}
  angle_current=${angle[-2]}
  good="false"
  while [ "false" = "$good" ]; do
    i=$(ros2 topic echo --once /odom)
    angle=($(python3 getAngleToTarget2.py $i $side))
    angle_current=${angle[-2]}
    delta="3.0"
    good=($(python3 compareAngles.py $delta $angel_target $angle_current))

    rollingSpeed=($(python3 getRollingSpeed.py $angel_target $angle_current))

    speedString=" "${rollingSpeed[0]}" "${rollingSpeed[1]}" "${rollingSpeed[2]}" "${rollingSpeed[3]}" "${rollingSpeed[4]}" "${rollingSpeed[5]}" "${rollingSpeed[6]}" "${rollingSpeed[7]}" "${rollingSpeed[8]}" "${rollingSpeed[9]}" "${rollingSpeed[10]}" "${rollingSpeed[11]}" "${rollingSpeed[12]}
    echo  'RollingSpeed='$speedString' angle1='${angle[-1]}' angle2='${angle[-2]}
    mycommand='ros2 topic pub --once /cmd_vel geometry_msgs/Twist '$speedString
    eval $mycommand
  done
  ros2 topic pub --once /cmd_vel geometry_msgs/Twist '{linear:  {x: 0.0, y: 0.0, z: 0.0}, angular: {x: 0.0,y: 0.0,z: 0.0}}'
}

targetX="1"
targetY="0.4"

set_k_b $targetX $targetY
echo "k="$k
echo "b="$b

online="False"
#checkOnLine
#echo $online
#set_k_b $targetX $targetY


function archMotion() {
    while [ "false" = "$goal" ]; do
        online="False"
        side="none"
        echo "moveToTargetWithStop START"
        moveToTargetWithStop $targetX $targetY
        echo "moveToTargetWithStop DONE"

        if [ "true" = "$goal" ]
          then
            echo "goal REACHED"
            break
        fi

        while [ "$online" = "False" ]; do
            set_distanceL $targetX $targetY
            #L1=$distanceL
            echo "rollingForOrtogonal START"
            rollingForOrtogonal $side
            echo "rollingForOrtogonal DONE"
            echo "movingFront START"
            movingFront
            if [ "$online" = "True" ]
              then
                echo "moving online"
                break
            fi
            echo "movingFront DONE"
            echo "turn90 START"
            turn90 $side
            echo "turn90 DONE"
            set_distanceL $targetX $targetY
            #L2=$distanceL
            echo "movingFront2 START"
            movingFront
            if [ "$online" = "True" ]
              then
                echo "moving online"
                break
            fi
            echo "movingFront2 DONE"
            set_distanceL $targetX $targetY
            #L3=$distanceL
        done

    done
}

archMotion

