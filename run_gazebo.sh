#!/bin/bash

source /opt/ros/humble/setup.bash

export TURTLEBOT3_MODEL=burger

export GAZEBO_MODEL_PATH=$GAZEBO_MODEL_PATH:`ros2 pkg \
prefix turtlebot3_gazebo \
`/share/turtlebot3_gazebo/models/

ros2 launch turtlebot3_gazebo cabinet.launch.py