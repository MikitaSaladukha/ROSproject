#!/bin/bash

myid=$(xdotool getactivewindow)
xdotool search --class "terminal" | while read id
do
  if [ "$id" != "$myid" ]
  then
      xdotool windowactivate "$id" &>/dev/null
      xdotool key ctrl+shift+q
      sleep 0.2
  fi
done