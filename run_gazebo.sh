#!/bin/bash

#Это запустить отдельно каждой командой, не скриптом (в первый раз). Далее можно скриптом запускать (возможно экспорты нужно каждый раз писать, а вот команду запуска газебо нужно в отдельном терминале запускать)


source /opt/ros/humble/setup.bash

export TURTLEBOT3_MODEL=burger

export GAZEBO_MODEL_PATH=$GAZEBO_MODEL_PATH:`ros2 pkg \
prefix turtlebot3_gazebo \
`/share/turtlebot3_gazebo/models/

ros2 launch turtlebot3_gazebo cabinet.launch.py