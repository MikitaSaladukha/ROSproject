#!/bin/bash

T0=$(date +%s)

while [ $(( `date +%s` - T0 )) -lt 10 ]; do
  [ -z "$(xdotool $@ 2>&1)" ] && break
  myid=$(xdotool getactivewindow)
  xdotool search --class "gnome-terminal" | while read id
  do
    if [ "$id" != "$myid" ]
    then
        xdotool windowactivate "$id" &>/dev/null
        xdotool key ctrl+shift+q
        sleep 0.2
    fi
  done
done



