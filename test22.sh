source /opt/ros/humble/setup.bash
#chmod +x stop_motion_command.sh
> waiting.txt
{
  {
  restart_lag_counter=0
  echo "started"
  while [ "True" = "True" ]; do
    PID=($(cat pid.txt))
    #$(ps -C stop_motion_command.sh -o pid)

    echo "PID="$PID
    numberOfLines=$(wc -l < waiting.txt)
    lastLine=$(tail -n 1 waiting.txt)
    line25=$(sed '25q;d' waiting.txt)
    echo "lastLine="$lastLine
    echo "line25="$line25
    sleep 1
    if [ "$lastLine" = "Waiting for at least 1 matching subscription(s)..." ]
      then
        echo "restart countdown: "$((25-$numberOfLines))
    fi
    if [ "$line25" = "Waiting for at least 1 matching subscription(s)..." ]
      then
        restart="True"
        echo "restarting"
        kill $PID
        > waiting.txt
        break
    fi
  done
  echo "exited while"
  #killall ros2
  #newpid= $(find / 2> /dev/null > /dev/null &)
  #echo "newpid="$(ps)
  #echo $? > exit_code.txt
  } & (ros2 topic pub --once /cmd_vel geometry_msgs/Twist '{linear:  {x: 0.0, y: 0.0, z: 0.0}, angular: {x: 0.0,y: 0.0,z: 0.0}}') > waiting.txt & echo $! > pid.txt
} || echo "command finished"

echo "continuing"

