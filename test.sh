#!/bin/bash
source /opt/ros/humble/setup.bash

i=$(ros2 topic echo --once /odom)
echo $i
#ros2 topic pub --once /cmd_vel geometry_msgs/Twist '{linear:  {x: -0.1, y: 0.0, z: 0.0}, angular: {x: 0.0,y: 0.0,z: 0.0}}'
python3 main.py $i
#sleep 10
#ros2 topic pub --once /cmd_vel geometry_msgs/Twist '{linear:  {x: 0.0, y: 0.0, z: 0.0}, angular: {x: 0.0,y: 0.0,z: 0.0}}'

