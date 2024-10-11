#!/bin/bash
source /opt/ros/humble/setup.bash

simualtion_area="cabinet"

#cabinet begin
targetX="3"
targetY="3"
max_number_of_steps_per_episode=50
max_episodes_number=100
max_episode_reward="100.0"
#cabinet end

export simualtion_area="$simualtion_area"



chmod +x run_gazebo.sh
chmod +x close_terminals.sh
gnome-terminal -e 'sh -c "source /opt/ros/humble/setup.bash; export TURTLEBOT3_MODEL=burger; export GAZEBO_MODEL_PATH=$GAZEBO_MODEL_PATH:`ros2 pkg prefix turtlebot3_gazebo `/share/turtlebot3_gazebo/models/; ros2 launch turtlebot3_gazebo $simualtion_area.launch.py"'
sleep 7


set_global=($(python3 global_values.py $targetX $targetY))
echo ${set_global[0]}" "${set_global[1]}" "${set_global[2]}" "${set_global[3]}" "${set_global[4]}" "${set_global[5]}" "${set_global[6]}" "${set_global[7]}
#
#chmod +x run_gazebo.sh
#gnome-terminal -- ./run_gazebo.sh
#sleep 10
#echo $(pwd)

function stop_gazebo(){
  killall -9 gazebo & killall -9 gzserver  & killall -9 gzclient
  #pgrep bash | xargs -r -n1 pstree -p -c | grep -v \- | grep -o '[0-9]\+' | xargs -r kill
  sleep 7
  ./close_terminals.sh


}

#cubes cilinders begin
#targetX="9"
#targetY="0"
#cubes cilinders end

#cubes:
#targetX="9"
#targetY="-1" # положительные у слева, отрицательные справа

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

#good="false"
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

online="False"
function checkOnLine() {
  i=$(ros2 topic echo --once /odom)

  XYcurrent=($(python3 getCurrXY.py $i))
  Xcurr=${XYcurrent[0]};
  Ycurr=${XYcurrent[1]};
  #echo "Xcurr="$Xcurr" Ycurr="$Ycurr
  online=($(python3 isOnLineXYkb.py $Xcurr $Ycurr $k $b))


}
side="none"
closeDistance="0.9"
function moveToTargetWithStop() {
  side="none"
  goal="false"
  near="false"
  x_target=$1
  y_target=$2
  while [ "false" = "$goal" ]; do

    roundToTarget $1 $2


    echo "check GOAL"
    i=$(ros2 topic echo --once /odom)
    XYcurrent=($(python3 getAngleToTarget.py $i $x_target $y_target))
    Xcurr=${XYcurrent[0]};
    Ycurr=${XYcurrent[1]};
    delta="0.25"
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
    while [ "$i" = "Waiting for at least 1 matching subscription(s)..." ]; do
      i=$(ros2 topic echo --once /scan -f)
    done
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
    ros2 topic pub --once /cmd_vel geometry_msgs/Twist '{linear:  {x: 0.07, y: 0.0, z: 0.0}, angular: {x: 0.0,y: 0.0,z: 0.0}}'
    #sleep 4

    echo "near="$near" side="$side" closest angle="$angle
    if [ $near = "true" ]
      then
        ros2 topic pub --once /cmd_vel geometry_msgs/Twist '{linear:  {x: 0.0, y: 0.0, z: 0.0}, angular: {x: 0.0,y: 0.0,z: 0.0}}'
        break
    fi

    i=$(ros2 topic echo --once /scan -f)
    while [ "$i" = "Waiting for at least 1 matching subscription(s)..." ]; do
      i=$(ros2 topic echo --once /scan -f)
    done
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
    delta="0.25"
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
    while [ "$i" = "Waiting for at least 1 matching subscription(s)..." ]; do
      i=$(ros2 topic echo --once /scan -f)
    done
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
    delta="0.25"
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
  echo "started rollingForOrtogonal"
  command="rolling"
  side=$1
  echo "after start of rollingForOrtogonal: side="$side
  while [ "good" != "$command" ]; do
    i=$(ros2 topic echo --once /scan -f)
    while [ "$i" = "Waiting for at least 1 matching subscription(s)..." ]; do
      i=$(ros2 topic echo --once /scan -f)
    done
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
  echo "ended rollingForOrtogonal"

}
moving="moving"
function movingFront() {
  moving="moving"
  ros2 topic pub --once /cmd_vel geometry_msgs/Twist '{linear:  {x: 0.06, y: 0.0, z: 0.0}, angular: {x: 0.0,y: 0.0,z: 0.0}}'
  #sleep 2
  while [ "moving" = "$moving" ]; do
    echo "checkOnline START"
    checkOnLine
    echo "checkOnline DONE; online="$online
    if [ "$online" = "True" ]
      then
        echo "moving online"
        moving="online"
        break
    fi

    ros2 topic pub --once /cmd_vel geometry_msgs/Twist '{linear:  {x: 0.03, y: 0.0, z: 0.0}, angular: {x: 0.0,y: 0.0,z: 0.0}}'
    i=$(ros2 topic echo --once /scan -f)
    while [ "$i" = "Waiting for at least 1 matching subscription(s)..." ]; do
      i=$(ros2 topic echo --once /scan -f)
    done
    moving=($(python3 movingFront.py $i $side "0.27" "0.37"))

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
    echo  'Turn90: RollingSpeed='$speedString' angle1='${angle[-1]}' angle2='${angle[-2]}
    mycommand='ros2 topic pub --once /cmd_vel geometry_msgs/Twist '$speedString
    eval $mycommand
  done
  ros2 topic pub --once /cmd_vel geometry_msgs/Twist '{linear:  {x: 0.0, y: 0.0, z: 0.0}, angular: {x: 0.0,y: 0.0,z: 0.0}}'
}





set_k_b $targetX $targetY
echo "k="$k
echo "b="$b

Lcloser="False"
closeExtent="0.09"
function closer() {
    L1=$1
    L2=$2
    diffL=($(python3 diffF1_F2.py $L1 $L2))
    diffExtent=($(python3 diffF1_F2.py $diffL $closeExtent))
    Lcloser=($(python3 biggerThanZero.py $diffExtent))
}

#checkOnLine
#echo $online
#set_k_b $targetX $targetY


function archMotion() {
    time1=($(python3 getTime.py))
    echo "Start time="$time1
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
        set_distanceL $targetX $targetY
        L1=$distanceL
        echo "L1="$L1
        echo "rollingForOrtogonal START"
        rollingForOrtogonal $side
        echo "rollingForOrtogonal DONE"
        echo "L1="$L1
        while [ "$online" = "False" -o "$Lcloser" = "False" ]; do
            echo "movingFront START"
            movingFront
            echo "movingFront DONE"
          ##########################################
            set_distanceL $targetX $targetY
            L2=$distanceL
            echo "L2="$L2"; L1="$L1
            closer $L1 $L2
            echo "Lcloser="$Lcloser
         ##############################################


            if [ "$online" = "True" -a "$Lcloser" = "True" ]
              then
                echo "moving online and closer"
                break
            fi

            if [ "$moving" = "far" ]
              then
                ros2 topic pub --once /cmd_vel geometry_msgs/Twist '{linear:  {x: -0.025, y: 0.0, z: 0.0}, angular: {x: 0.0,y: 0.0,z: 0.0}}'
                echo "turn90 START"
                turn90 $side
                echo "turn90 DONE"
            fi
            if [ "$moving" = "obstacle" ]
              then
                echo "rollingForOrtogonal START"
                rollingForOrtogonal $side
                echo "rollingForOrtogonal DONE"
            fi
        done
        set_distanceL $targetX $targetY
        #L3=$distanceL
    done
    time=($(python3 getTime.py))
    echo "Start time="$time1" End time="$time
}


function rollingForEdgeOfObstacle() {
  command="rolling"
  side=$1
  while [ "good" != "$command" ]; do
    i=$(ros2 topic echo --once /scan -f)
    while [ "$i" = "Waiting for at least 1 matching subscription(s)..." ]; do
      i=$(ros2 topic echo --once /scan -f)
    done
    command1=($(python3 rollingForEdge.py $i $side))
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

function turnToTargetAngle() {
  source /opt/ros/humble/setup.bash
  angleTarget=$1
  angleCurrent=$2
  rollingSpeed=($(python3 getRollingSpeed.py $angleTarget $angleCurrent))

  speedString=" "${rollingSpeed[0]}" "${rollingSpeed[1]}" "${rollingSpeed[2]}" "${rollingSpeed[3]}" "${rollingSpeed[4]}" "${rollingSpeed[5]}" "${rollingSpeed[6]}" "${rollingSpeed[7]}" "${rollingSpeed[8]}" "${rollingSpeed[9]}" "${rollingSpeed[10]}" "${rollingSpeed[11]}" "${rollingSpeed[12]}
  echo  'RollingSpeed='$speedString' angle1='${angle[-1]}' angle2='${angle[-2]}
  mycommand='ros2 topic pub --once /cmd_vel geometry_msgs/Twist '$speedString
  eval $mycommand
}

function roundToTargetAngle() {
  angleTarget=$1
  #angleCurrent=$2
  good="false"

  while [ "false" = "$good" ]
  do
    i=$(ros2 topic echo --once /odom)
    angle=($(python3 getAngleToTargetAngle.py $i))
    angleCurrent=${angle[-1]}
    echo "current angle="$angleCurrent
    turnToTargetAngle $angleTarget $angleCurrent
    i=$(ros2 topic echo --once /odom)
    angle=($(python3 getAngleToTargetAngle.py $i))
    angleCurrent=${angle[-1]}
    echo "current angle="$angleCurrent
    delta="3.0"
    good=($(python3 compareAngles.py $delta $angleTarget $angleCurrent))
  done
  ros2 topic pub --once /cmd_vel geometry_msgs/Twist '{linear:  {x: 0.0, y: 0.0, z: 0.0}, angular: {x: 0.0,y: 0.0,z: 0.0}}'
}

function movingFront2() {
  moving="moving"

  #x: = 0.85 - не огибает, слишком медленно

    #x: = 1.59, 1.0, 0.94, 0.85, 0.75 - не огибает, слишком быстро
    # x=0.65 - врезается, 0.55- слишком медленно

  ros2 topic pub --once /cmd_vel geometry_msgs/Twist '{linear:  {x: 0.6, y: 0.0, z: 0.0}, angular: {x: 0.0,y: 0.0,z: 0.0}}'
  #sleep 2
  while [ "moving" = "$moving" ]; do

     #x: = 0.65 - не огибает, слишком медленно

    #x: = 0.85,  0.8,0.72, 0.68, 0.13, 0.085, 0.05 - не огибает, слишком быстро
    ros2 topic pub --once /cmd_vel geometry_msgs/Twist '{linear:  {x: 0.02, y: 0.0, z: 0.0}, angular: {x: 0.0,y: 0.0,z: 0.0}}'

    echo "check GOAL"
    i=$(ros2 topic echo --once /odom)
    XYcurrent=($(python3 getAngleToTarget.py $i $targetX $targetY))
    Xcurr=${XYcurrent[0]};
    Ycurr=${XYcurrent[1]};
    delta="0.25"
    good1=($(python3 isEqualFloat.py $delta $targetX $Xcurr))
    good2=($(python3 isEqualFloat.py $delta $targetY $Ycurr))
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
    while [ "$i" = "Waiting for at least 1 matching subscription(s)..." ]; do
      i=$(ros2 topic echo --once /scan -f)
    done

    moving=($(python3 movingFront.py $i $side "0.89" "0.97"))

    echo "moving="$moving
  done
  ros2 topic pub --once /cmd_vel geometry_msgs/Twist '{linear:  {x: 0.0, y: 0.0, z: 0.0}, angular: {x: 0.0,y: 0.0,z: 0.0}}'
}


closeDistance2="3.3"
openFreeDistance=$closeDistance
turnAngle="0.0"
closeDistanceInFrontStop="0.87"

function archMotion2() {
    echo "start vfh*"
    time1=($(python3 getTime.py))
    echo "Start time="$time1
    while [ "false" = "$goal" ]; do
#    echo "start round to target"
#    roundToTarget $targetX $targetY
#
#    echo "end round to target"
      echo "moveToTargetWithStop START"
      moveToTargetWithStop $targetX $targetY
      echo "moveToTargetWithStop DONE"

      if [ "true" = "$goal" ]
        then
          echo "goal REACHED"
          break
      fi

      i=$(ros2 topic echo --once /odom)
      angle=($(python3 getAngleToTarget.py $i $targetX $targetY))
      angel_target=${angle[-1]}
      angle_current=${angle[-2]}
      echo "angel_target="$angel_target
      echo "angle_current="$angle_current
      i=$(ros2 topic echo --once /scan -f)
      while [ "$i" = "Waiting for at least 1 matching subscription(s)..." ]; do
        i=$(ros2 topic echo --once /scan -f)
      done
      close=($(python3 getCandidateAngleSector.py $i $angle_current $angel_target $closeDistance))
      numberOfCandidateSectors=${close[0]}

      i=0
      echo "numberOfCandidateSectors="$numberOfCandidateSectors

      while [ $i -lt $numberOfCandidateSectors ]; do
        start=$((1+$i))
        end=$(($i+2))
        obstacleStart=$(($i+3))
        obstacleEnd=$(($i+4))
        i=$(($i+4))
        echo "angleSector"$i"=["${close[$start]}","${close[$end]}"] in distances=["${close[$obstacleStart]}","${close[$obstacleEnd]}"]"
      done

      echo "turn_target="${close[$(($obstacleEnd+1))]}
      echo "directon of sector="${close[$(($obstacleEnd+2))]}
      echo "turn target delta="${close[$(($obstacleEnd+3))]}
      echo "openFreeDistance="${close[$(($obstacleEnd+4))]}
      echo "relative target angle="${close[$(($obstacleEnd+5))]}
      echo "relative target angle with minus="${close[$(($obstacleEnd+6))]}


      echo "minus_relative_target_angle360="${close[$(($obstacleEnd+7))]}

      echo "broadth="${close[$(($obstacleEnd+8))]}
      echo "inverse obstacle="${close[$(($obstacleEnd+9))]}
  #    echo "4="${close[$(($obstacleEnd+10))]}
  #
  #    echo "5="${close[$(($obstacleEnd+11))]}
  #    echo "6="${close[$(($obstacleEnd+12))]}



      openFreeDistance=${close[$(($obstacleEnd+4))]}
      turnAngle=${close[$(($obstacleEnd+1))]}
      #target angle currenctly = 90
      echo "start turning by vfh*"
      roundToTargetAngle $turnAngle
      echo "end turning by vfh*"

      i=$(ros2 topic echo --once /odom)
      XYcurrentPrevious=($(python3 getCurrXY.py $i))
      XcurrPrevious=${XYcurrent[0]};
      YcurrPrevious=${XYcurrent[1]};

      echo "started motion by vfh*"
      ros2 topic pub --once /cmd_vel geometry_msgs/Twist '{linear:  {x: 0.06, y: 0.0, z: 0.0}, angular: {x: 0.0,y: 0.0,z: 0.0}}'
      while [ "true" = "true" ]; do
        ros2 topic pub --once /cmd_vel geometry_msgs/Twist '{linear:  {x: 0.06, y: 0.0, z: 0.0}, angular: {x: 0.0,y: 0.0,z: 0.0}}'
        i=$(ros2 topic echo --once /odom)
        XYcurrent=($(python3 getCurrXY.py $i))
        Xcurr=${XYcurrent[0]};
        Ycurr=${XYcurrent[1]};
        distanceL=($(python3 getDistance.py $XcurrPrevious $YcurrPrevious $Xcurr $Ycurr))

        L1=$distanceL
        L2=$openFreeDistance
        diffL=($(python3 diffF1_F2.py $L1 $L2))
        diffExtent=($(python3 diffF1_F2.py $diffL $closeExtent))
        Lcloser=($(python3 biggerThanZero.py $diffExtent))
        echo "distanceL="$L1
        echo "openFreeDistance="$openFreeDistance
        echo "diffL="$diffL
        echo "diffExtent="$diffExtent
        echo "Lcloser="$Lcloser
        if [ "True" = "$Lcloser" ]
            then
              echo "distance moved by vfh*"
              Lcloser="False"
              break
        fi
        echo "check GOAL"
        i=$(ros2 topic echo --once /odom)
        XYcurrent=($(python3 getAngleToTarget.py $i $targetX $targetY))
        Xcurr=${XYcurrent[0]};
        Ycurr=${XYcurrent[1]};
        delta="0.25"
        good1=($(python3 isEqualFloat.py $delta $targetX $Xcurr))
        good2=($(python3 isEqualFloat.py $delta $targetY $Ycurr))
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


      ros2 topic pub --once /cmd_vel geometry_msgs/Twist '{linear:  {x: 0.0, y: 0.0, z: 0.0}, angular: {x: 0.0,y: 0.0,z: 0.0}}'


    done
    i=$(ros2 topic echo --once /scan -f)
    while [ "$i" = "Waiting for at least 1 matching subscription(s)..." ]; do
      i=$(ros2 topic echo --once /scan -f)
    done

    close=($(python3 getClosestAngleDist.py $i "3.5"))
    side=${close[-1]}
    time=($(python3 getTime.py))
    echo "Start time="$time1" End time="$time
}
# если расстояние до цели увеличивается при движении - использовать начальный (первый) алгоритм движения вдоль препрятствия.
# если расстояние сокращается - начать использовать новый алгортим огибания vfh
#





function bugMotionArch() {
        echo "BUG motion STARTED"
        if [ "true" = "$goal" ]
          then
            echo "goal REACHED"
            return
        fi
        set_distanceL $targetX $targetY
        L1=$distanceL
        echo "L1="$L1
        echo "rollingForOrtogonal START"
        rollingForOrtogonal $side
        echo "rollingForOrtogonal DONE"
        echo "L1="$L1
        while [ "$Lcloser" = "False" ]; do
            echo "movingFront2 START"
            movingFront2
            echo "movingFront2 DONE"
        ###########################################
            echo "check GOAL"
            i=$(ros2 topic echo --once /odom)
            XYcurrent=($(python3 getAngleToTarget.py $i $targetX $targetY))
            Xcurr=${XYcurrent[0]};
            Ycurr=${XYcurrent[1]};
            delta="0.25"
            good1=($(python3 isEqualFloat.py $delta $targetX $Xcurr))
            good2=($(python3 isEqualFloat.py $delta $targetY $Ycurr))
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
          ##########################################
            set_distanceL $targetX $targetY
            L2=$distanceL
            echo "L2="$L2"; L1="$L1
            closer $L1 $L2
            echo "Lcloser="$Lcloser
         ##############################################

            if [ "$Lcloser" = "True" ]
              then
                echo "moved closer"
                #ros2 topic pub --once /cmd_vel geometry_msgs/Twist '{linear:  {x: -0.025, y: 0.0, z: 0.0}, angular: {x: 0.0,y: 0.0,z: 0.0}}'
                break
            fi
            if [ "$moving" = "far" ]
              then
                #ros2 topic pub --once /cmd_vel geometry_msgs/Twist '{linear:  {x: -0.025, y: 0.0, z: 0.0}, angular: {x: 0.0,y: 0.0,z: 0.0}}'
                echo "turn90 START"
                turn90 $side
                echo "turn90 DONE"
            fi
            if [ "$moving" = "obstacle" ]
              then
                echo "rollingForOrtogonal START"
                rollingForOrtogonal $side
                echo "rollingForOrtogonal DONE"

                set_distanceL $targetX $targetY
                L1=$distanceL
                echo "After rolling for ortogonal set L1="$L1
            fi
        done
        #set_distanceL $targetX $targetY
        #L3=$distanceL
        ros2 topic pub --once /cmd_vel geometry_msgs/Twist '{linear:  {x: -0.0, y: 0.0, z: 0.0}, angular: {x: 0.0,y: 0.0,z: 0.0}}'
        echo "BUG motion ENDED"
}

function rollingForObstacleInFront() {
  echo "started rollingForObstacleInFront"
  command="rolling"
  while [ "good" != "$command" ]; do
    i=$(ros2 topic echo --once /scan -f)
    while [ "$i" = "Waiting for at least 1 matching subscription(s)..." ]; do
      i=$(ros2 topic echo --once /scan -f)
    done
    command1=($(python3 rollingForObstacleInFront.py $i))
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
  echo "ended rollingForObstacleInFront"
}


ZAPAS_PO_UGLU=11
bigger0="False"
bigger1="False"

function additionalTurning() {
  echo "additionalTurning started"
  bigger0="False"
  bigger1="False"
  while [ "False" = "$bigger1" -o "False" = "$bigger0" ]; do
    ###############check close distance in front###start
    i=$(ros2 topic echo --once /scan -f)
    while [ "$i" = "Waiting for at least 1 matching subscription(s)..." ]; do
      i=$(ros2 topic echo --once /scan -f)
    done
    distanceAngle=($(python3 getDistanceFromAngle.py $i $ZAPAS_PO_UGLU))
    tempDif=($(python3 diffF1_F2.py $distanceAngle $openFreeDistance))
    bigger0=($(python3 biggerThanZero.py $tempDif))
    if [ "False" = "$bigger0" ]
      then ##ROLLING MINUS
        echo "Additional turning minus"
        ros2 topic pub --once /cmd_vel geometry_msgs/Twist '{linear:  {x: 0.0, y: 0.0, z: 0.0}, angular: {x: 0.0,y: 0.0,z: -0.01}}'
      else
    ###############check close distance in front###end
        i=$(ros2 topic echo --once /scan -f)
        while [ "$i" = "Waiting for at least 1 matching subscription(s)..." ]; do
          i=$(ros2 topic echo --once /scan -f)
        done
        distanceAngle=($(python3 getDistanceFromAngle.py $i $((360-$ZAPAS_PO_UGLU))))
        tempDif=($(python3 diffF1_F2.py $distanceAngle $openFreeDistance))
        bigger1=($(python3 biggerThanZero.py $tempDif))
        if [ "False" = "$bigger1" ]
          then ##ROLLING PlUS
            echo "Additional turning plus"
            ros2 topic pub --once /cmd_vel geometry_msgs/Twist '{linear:  {x: 0.0, y: 0.0, z: 0.0}, angular: {x: 0.0,y: 0.0,z: 0.01}}'
        fi
    fi
    echo "bigger0="$bigger0" bigger1="$bigger1
  done
  ros2 topic pub --once /cmd_vel geometry_msgs/Twist '{linear:  {x: 0.0, y: 0.0, z: 0.0}, angular: {x: 0.0,y: 0.0,z: 0.0}}'
  echo "additionalTurning finished"
}

function vfhMotion() {
    echo "START vfh* single"
    i=$(ros2 topic echo --once /odom)
    angle=($(python3 getAngleToTarget.py $i $targetX $targetY))
    angel_target=${angle[-1]}
    angle_current=${angle[-2]}
    echo "angel_target="$angel_target
    echo "angle_current="$angle_current
    i=$(ros2 topic echo --once /scan -f)
    while [ "$i" = "Waiting for at least 1 matching subscription(s)..." ]; do
      i=$(ros2 topic echo --once /scan -f)
    done
    close=($(python3 getCandidateAngleSector.py $i $angle_current $angel_target $closeDistance))
    numberOfCandidateSectors=${close[0]}

    i=0
    echo "numberOfCandidateSectors="$numberOfCandidateSectors
    expanded_i_numberofCandidateSectors=($(python3 multiply_I1_I2.py "4" $numberOfCandidateSectors))
    echo "expanded_i_numberofCandidateSectors="$expanded_i_numberofCandidateSectors

    while [ $i -lt $expanded_i_numberofCandidateSectors ]; do
      start=$((1+$i))
      end=$(($i+2))
      obstacleStart=$(($i+3))
      obstacleEnd=$(($i+4))
      echo "angleSector"$i"=["${close[$start]}","${close[$end]}"] in distances=["${close[$obstacleStart]}","${close[$obstacleEnd]}"]"
      i=$(($i+4))
    done

    echo "turn_target="${close[$(($obstacleEnd+1))]}
    echo "directon of sector="${close[$(($obstacleEnd+2))]}
    echo "turn target delta="${close[$(($obstacleEnd+3))]}
    echo "openFreeDistance="${close[$(($obstacleEnd+4))]}
    echo "relative target angle="${close[$(($obstacleEnd+5))]}
    echo "relative target angle with minus="${close[$(($obstacleEnd+6))]}


    echo "minus_relative_target_angle360="${close[$(($obstacleEnd+7))]}

    echo "broadth="${close[$(($obstacleEnd+8))]}
    echo "inverse obstacle="${close[$(($obstacleEnd+9))]}

    echo "delta1(i=0,relative_target_angle - 360)="${close[$(($obstacleEnd+10))]}
    echo "delta2(i=0,360 + relative_target_angle)="${close[$(($obstacleEnd+11))]}
    echo "delta3(relative_target_angle - 360)="${close[$(($obstacleEnd+12))]}
    echo "delta4(360 + relative_target_angle)="${close[$(($obstacleEnd+13))]}
    echo "delta5(relative_target_angle)="${close[$(($obstacleEnd+14))]}
    openFreeDistance=${close[$(($obstacleEnd+4))]}
    turnAngle=${close[$(($obstacleEnd+1))]}
    echo "start turning by vfh*"
    roundToTargetAngle $turnAngle
    echo "end turning by vfh*"

#    ###############check close distance in front###start
#    i=$(ros2 topic echo --once /scan -f)
#    distanceAngle=($(python3 getDistanceFromAngle.py $i "0"))
#    tempDif=($(python3 diffF1_F2.py $distanceAngle $closeDistanceInFrontStop))
#    bigger0=($(python3 biggerThanZero.py $tempDif))
#    if [ "False" = "$bigger0" ]
#      then
#        ros2 topic pub --once /cmd_vel geometry_msgs/Twist '{linear:  {x: 0.0, y: 0.0, z: 0.0}, angular: {x: 0.0,y: 0.0,z: 0.0}}'
#        echo "obstacle to close in front. vfhMotion stopped"#
#        return
#    fi
#    ###############check close distance in front###end

    additionalTurning


    i=$(ros2 topic echo --once /odom)
    XYcurrentPrevious=($(python3 getCurrXY.py $i))
    XcurrPrevious=${XYcurrent[0]};
    YcurrPrevious=${XYcurrent[1]};

    echo "started motion by vfh*"
    ros2 topic pub --once /cmd_vel geometry_msgs/Twist '{linear:  {x: 0.06, y: 0.0, z: 0.0}, angular: {x: 0.0,y: 0.0,z: 0.0}}'
    while [ "true" = "true" ]; do
      ###############check close distance in front###start
      i=$(ros2 topic echo --once /scan -f)
      while [ "$i" = "Waiting for at least 1 matching subscription(s)..." ]; do
        i=$(ros2 topic echo --once /scan -f)
      done
      distanceAngle=($(python3 getDistanceFromAngle.py $i "0"))
      tempDif=($(python3 diffF1_F2.py $distanceAngle $closeDistanceInFrontStop))
      bigger0=($(python3 biggerThanZero.py $tempDif))
      if [ "False" = "$bigger0" ]
        then
          ros2 topic pub --once /cmd_vel geometry_msgs/Twist '{linear:  {x: 0.0, y: 0.0, z: 0.0}, angular: {x: 0.0,y: 0.0,z: 0.0}}'
          echo "obstacle to close in front. vfhMotion stopped"
          return
      fi
      ###############check close distance in front###end
      ros2 topic pub --once /cmd_vel geometry_msgs/Twist '{linear:  {x: 0.06, y: 0.0, z: 0.0}, angular: {x: 0.0,y: 0.0,z: 0.0}}'
      i=$(ros2 topic echo --once /odom)
      XYcurrent=($(python3 getCurrXY.py $i))
      Xcurr=${XYcurrent[0]};
      Ycurr=${XYcurrent[1]};
      distanceL=($(python3 getDistance.py $XcurrPrevious $YcurrPrevious $Xcurr $Ycurr))

      L1=$distanceL
      L2=$openFreeDistance
      diffL=($(python3 diffF1_F2.py $L1 $L2))
      diffExtent=($(python3 diffF1_F2.py $diffL $closeExtent))
      Lcloser=($(python3 biggerThanZero.py $diffExtent))
      echo "distanceL="$L1
      echo "openFreeDistance="$openFreeDistance
      echo "diffL="$diffL
      echo "diffExtent="$diffExtent
      echo "Distance reached="$Lcloser
      if [ "True" = "$Lcloser" ]
          then
            echo "distance moved by vfh*"
            Lcloser="False"
            break
      fi
      echo "check GOAL"
      i=$(ros2 topic echo --once /odom)
      XYcurrent=($(python3 getAngleToTarget.py $i $targetX $targetY))
      Xcurr=${XYcurrent[0]};
      Ycurr=${XYcurrent[1]};
      delta="0.25"
      good1=($(python3 isEqualFloat.py $delta $targetX $Xcurr))
      good2=($(python3 isEqualFloat.py $delta $targetY $Ycurr))
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
      while [ "$i" = "Waiting for at least 1 matching subscription(s)..." ]; do
        i=$(ros2 topic echo --once /scan -f)
      done
      close=($(python3 getClosestAngleDist.py $i "3.6"))
      sideTemp=${close[-1]}
      angle=${close[-2]}
      if [ "none" != "$sideTemp" ]
          then
            side=$sideTemp
      fi
      echo "temporal vfh: sideTemp="$sideTemp
      echo "temporal vfh: angle="$angle
      echo "temporal vfh: side="$side

      ###############check close distance in front###start
      i=$(ros2 topic echo --once /scan -f)
      while [ "$i" = "Waiting for at least 1 matching subscription(s)..." ]; do
        i=$(ros2 topic echo --once /scan -f)
      done
      distanceAngle=($(python3 getDistanceFromAngle.py $i "0"))
      tempDif=($(python3 diffF1_F2.py $distanceAngle $closeDistanceInFrontStop))
      bigger0=($(python3 biggerThanZero.py $tempDif))
      if [ "False" = "$bigger0" ]
        then
          ros2 topic pub --once /cmd_vel geometry_msgs/Twist '{linear:  {x: 0.0, y: 0.0, z: 0.0}, angular: {x: 0.0,y: 0.0,z: 0.0}}'
          echo "obstacle to close in front. vfhMotion stopped"
          return
      fi
      ###############check close distance in front###end


    done


    ros2 topic pub --once /cmd_vel geometry_msgs/Twist '{linear:  {x: 0.0, y: 0.0, z: 0.0}, angular: {x: 0.0,y: 0.0,z: 0.0}}'




    i=$(ros2 topic echo --once /scan -f)
    while [ "$i" = "Waiting for at least 1 matching subscription(s)..." ]; do
      i=$(ros2 topic echo --once /scan -f)
    done
    close=($(python3 getClosestAngleDist.py $i "3.6"))
    sideTemp=${close[-1]}
    angle=${close[-2]}
    if [ "none" != "$sideTemp" ]
        then
          side=$sideTemp
    fi
    echo "after vfh: side="$side
    echo "after vfh: angle="$angle
    echo "END vfh* single"
}

function archMotion3() {
    echo "start modified vfh*"
    time1=($(python3 getTime.py))
    echo "Start time="$time1
    while [ "false" = "$goal" ]; do
      echo "moveToTargetWithStop START"
      moveToTargetWithStop $targetX $targetY
      echo "moveToTargetWithStop DONE"
      if [ "true" = "$goal" ]
        then
          echo "goal REACHED"
          break
      fi
      set_distanceL $targetX $targetY
      L1my=$distanceL
      echo "L1 before vfh single="$L1my
      echo "Started vfh motion"
      vfhMotion
      echo "Ended vfh motion"
      set_distanceL $targetX $targetY
      L2my=$distanceL
      echo "L1 after (before) vfh single="$L1my
      echo "L2 after vfh single="$L2my

      closer $L1my $L2my
      echo "BEFORE BUG motion checked Lcloser="$Lcloser

      if [ "False" = "$Lcloser" ]
      then
        echo "Started bug motion"
        bugMotionArch
        echo "Ended bug motion"
      fi

    done
    time=($(python3 getTime.py))
    echo "Start time="$time1" End time="$time
}

firstCheck="false"
function bugMotion() {

        #side="left_side"
        firstCheck="false"
        zeroCheck="false"
        echo "BUG motion STARTED"
        if [ "true" = "$goal" ]
          then
            echo "goal REACHED"
            return
        fi

        echo "rollingForOrtogonal START"
        rollingForOrtogonal $side
        echo "rollingForOrtogonal DONE"
        echo "L1="$L1
        while [ "True" = "True" ]; do
            echo "movingFront2 START"
            movingFront2
            echo "movingFront2 DONE"
        ###########################################
            echo "check GOAL"
            i=$(ros2 topic echo --once /odom)
            XYcurrent=($(python3 getAngleToTarget.py $i $targetX $targetY))
            Xcurr=${XYcurrent[0]};
            Ycurr=${XYcurrent[1]};
            delta="0.25"
            good1=($(python3 isEqualFloat.py $delta $targetX $Xcurr))
            good2=($(python3 isEqualFloat.py $delta $targetY $Ycurr))
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

            if [ "$moving" = "far" ]
              then
                if [ "$firstCheck" = "true" ]
                  then
                    echo "bug far BREAK"
                    break
                fi
                #ros2 topic pub --once /cmd_vel geometry_msgs/Twist '{linear:  {x: -0.025, y: 0.0, z: 0.0}, angular: {x: 0.0,y: 0.0,z: 0.0}}'
                echo "turn90 START"
                turn90 $side
                echo "turn90 DONE"
                if [ "$zeroCheck" = "true" ]
                  then
                    firstCheck="true"
                    echo "firstCheck set to true"
                fi
                zeroCheck="true"
                echo "zeroCheck set to true"
            fi
            if [ "$moving" = "obstacle" ]
              then
                if [ "$firstCheck" = "true" ]
                  then
                    echo "bug obstacle BREAK"
                    break
                  fi
                echo "rollingForOrtogonal START"
                rollingForOrtogonal $side
                echo "rollingForOrtogonal DONE"
                firstCheck="true"
                echo "firstCheck set to true"

            fi
        done
        #set_distanceL $targetX $targetY
        #L3=$distanceL
        ros2 topic pub --once /cmd_vel geometry_msgs/Twist '{linear:  {x: -0.0, y: 0.0, z: 0.0}, angular: {x: 0.0,y: 0.0,z: 0.0}}'
        echo "BUG motion ENDED"
}
function bugMotionLeftSide() {
  side="left_side"
  bugMotionQ_vfh
}

function bugMotionRightSide() {
  side="right_side"
  bugMotionQ_vfh
}

function bugMotionQ_vfh() {
    i=$(ros2 topic echo --once /scan -f)
    while [ "$i" = "Waiting for at least 1 matching subscription(s)..." ]; do
      i=$(ros2 topic echo --once /scan -f)
    done
    close_t=($(python3 getClosestAngleDist.py $i "1.31")) #было 0.93
    sideTemp=${close_t[-1]}
    angle=${close_t[-2]}
    echo "sideTemp="$sideTemp
    if [ $sideTemp == "none" ]
        then
          motionVariant="vfh"
          vfhMotion
        else
          bugMotion
    fi

}

total_episode_reward="0"
function motionAccordingToQtable() {
  i=$(ros2 topic echo --once /odom)
  XYcurrent=($(python3 getCurrXY.py $i))
  Xprev=${XYcurrent[0]};
  Yprev=${XYcurrent[1]};

#  get_from_blockchain

  motionVariant=($(python3 get_qtable_action.py $Xprev $Yprev))
  echo $motionVariant
  if [ "vfh" = "$motionVariant" ]
    then
      vfhMotion
  fi
  if [ "bug_left" = "$motionVariant" ]
    then
      bugMotionLeftSide
  fi
  if [ "bug_right" = "$motionVariant" ]
    then
      bugMotionRightSide
  fi
  i=$(ros2 topic echo --once /odom)
  XYcurrent=($(python3 getCurrXY.py $i))
  Xcurr=${XYcurrent[0]};
  Ycurr=${XYcurrent[1]};

  qtableUpdated=($(python3 update_qtable.py $Xcurr $Ycurr $Xprev $Yprev $motionVariant))
  echo ${qtableUpdated[0]}" "${qtableUpdated[1]}" "${qtableUpdated[2]}" "${qtableUpdated[3]}" "${qtableUpdated[4]}" "${qtableUpdated[5]}" "${qtableUpdated[6]}" "${qtableUpdated[7]}" "${qtableUpdated[8]}" "${qtableUpdated[9]}" "${qtableUpdated[10]}" "${qtableUpdated[11]}" "${qtableUpdated[12]}" "

  total_episode_reward=($(python3 summValuesFloat.py ${qtableUpdated[12]} $total_episode_reward))

#  save_to_blockchain
}



function OneEpisodeMotion() {
  set_global=($(python3 global_values.py $targetX $targetY))
  echo ${set_global[0]}" "${set_global[1]}" "${set_global[2]}" "${set_global[3]}" "${set_global[4]}" "${set_global[5]}" "${set_global[6]}" "${set_global[7]}
  echo "episode_started"
  step_number=0
  while [ "True" = "True" ]; do
    echo "step_started"
#    i=$(ros2 topic echo --once /scan -f)
#    close=($(python3 getClosestAngleDist.py $i "2.93"))
#    side=${close[-1]}
#    angle=${close[-2]}
#    echo "side="$side


#    if [ $side == "none" ]
#        then
#          vfhMotion
#        else
#          motionAccordingToQtable
#    fi

    motionAccordingToQtable
    c=($(cat commands.txt))
    if [ $c = "pauseQ" ]
      then
        break
    fi


    step_number=$(($step_number+1))
    if [ "$step_number" -ge "$max_number_of_steps_per_episode" ]
      then
        echo "steps_limit_overcome"
        break
      else
        echo "step_finished"
    fi


    echo "check GOAL"
    i=$(ros2 topic echo --once /odom)
    XYcurrent=($(python3 getAngleToTarget.py $i $targetX $targetY))
    Xcurr=${XYcurrent[0]};
    Ycurr=${XYcurrent[1]};
    delta="0.25"
    good1=($(python3 isEqualFloat.py $delta $targetX $Xcurr))
    good2=($(python3 isEqualFloat.py $delta $targetY $Ycurr))
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

    echo "step_finished"
  done

  echo "one_learning_episode_FINISHED"


}
motionVariant="vfh"
#Xcurr="1.1"
#Ycurr="2.1"
#Xprev="-3.1"
#Yprev="-4.5"

TotalRewardBiggerThanMax="False"

function checkTotalReward() {
  echo "total_episode_reward="$total_episode_reward" compared to max="$max_episode_reward
  tempDif=($(python3 diffF1_F2.py $total_episode_reward $max_episode_reward))
  TotalRewardBiggerThanMax=($(python3 biggerThanZero.py $tempDif))
}

function saveRewardToFile() {
  echo $total_episode_reward >> reward.txt
}

function clearRewardFile() {
    > reward.txt
}
access_token=""
CID=""
CID_prev=""
function save_to_blockchain() {
    CID=""
    access_token=($(cat access_token.txt))
    ipfs pin remote service add IPFSservice https://api.4everland.dev $access_token
    while [ "$CID" = "" ]; do
      CID=($(ipfs add qtable.json))
    done
    CID=${CID[1]}
    echo "CID before adding="$CID
    adding=""
    adding=($(ipfs pin remote add --service=IPFSservice --name=qtable $CID))
    while [ "$adding" = "" ]; do
      sleep 1
    done
    CID_prev=$CID
    echo $CID_prev
    echo "saving to blockchain OK; adding="$adding
    ipfs pin add $CID_prev
}

function get_from_blockchain() {
  if [ "$CID_prev" != "" ]
    then
      ipfs get $CID_prev -o qtable.json
      while [ "True" = "True" ]; do
        if [ -s qtable.json ]
          then
              break
          else
              echo "saving from blockchain CID_prev="$CID_prev
              sleep 1
        fi
      done
      ipfs pin remote rm --service=IPFSservice --name=qtable --force
      echo "loaded qtable.json from blockchain"
    else
      echo "CID is not set"
  fi
}

function qMotion() {
  echo "null" > commands.txt
  python3 gui.py &
  while [ "True" = "True" ]; do
    sleep 1
    c=($(cat commands.txt))
    if [ $c = "start_from_null" -o $c = "start_from_existing" ]
      then
        break
    fi
  done
  if [ $c = "start_from_null" ]
      then
        text=($(python3 random_q_table.py))
        echo $text
        clearRewardFile
      else
        echo "continuing with existing q-table"
  fi
  episode_number=$(wc -l < reward.txt)
  echo "episode started from n="$episode_number
  while [ "True" = "True" ]; do
    echo "one_learning_episode_STARTED"
#    source /opt/ros/humble/setup.bash
#    export TURTLEBOT3_MODEL=burger
#    export GAZEBO_MODEL_PATH=$GAZEBO_MODEL_PATH:`ros2 pkg \
#    prefix turtlebot3_gazebo \
#    `/share/turtlebot3_gazebo/models/

#    gnome-terminal -- source /opt/ros/humble/setup.bash && export TURTLEBOT3_MODEL=burger && export GAZEBO_MODEL_PATH=$GAZEBO_MODEL_PATH:`ros2 pkg prefix turtlebot3_gazebo `/share/turtlebot3_gazebo/models/ && ros2 launch turtlebot3_gazebo cabinet.launch.py
#    gnome-terminal -- /bin/sh -c 'source /opt/ros/humble/setup.bash; export TURTLEBOT3_MODEL=burger; export GAZEBO_MODEL_PATH=$GAZEBO_MODEL_PATH:`ros2 pkg prefix turtlebot3_gazebo `/share/turtlebot3_gazebo/models/; ros2 launch turtlebot3_gazebo cabinet.launch.py'

    OneEpisodeMotion
    if [ $total_episode_reward !=  "0" ]
      then
        saveRewardToFile
    fi

    stop_gazebo
    #./close_terminals.sh
    echo "one_learning_episode_FINISHED"

    c=($(cat commands.txt))
    while [ $c = "pauseQ" ]; do
      echo "Paused"
      sleep 1
      c=($(cat commands.txt))
      if [ $c = "continueQ" ]
        then
          break
      fi
    done


    checkTotalReward
    if [ $TotalRewardBiggerThanMax = "True" ]
      then
        echo "Q-learning finished"
        break
    fi



    episode_number=$(($episode_number+1))
    if [ "$episode_number" -ge "$max_episodes_number" ]
      then
        echo "QLearning_finished_by_max_episode_number"
        break
      else
        echo "episode_finished"
    fi


    gnome-terminal -e 'sh -c "source /opt/ros/humble/setup.bash; export TURTLEBOT3_MODEL=burger; export GAZEBO_MODEL_PATH=$GAZEBO_MODEL_PATH:`ros2 pkg prefix turtlebot3_gazebo `/share/turtlebot3_gazebo/models/; ros2 launch turtlebot3_gazebo $simualtion_area.launch.py"'

    sleep 8
  done
  echo "EXIT"


}
#text=($(python3 random_q_table.py))
#echo $text
#save_to_blockchain
#get_from_blockchain

qMotion
#stop_gazebo
