#!/usr/bin/env bash

#rofi -show m -modi "m:/home/afabre/.dotfiles/config/rofi/monitors/monitors.sh"

SCRIPTSDIR="$HOME/.screenlayout"

if [ -n "$1" ]
then
    . "$1"
    "$HOME"/.config/polybar/launch.sh &
    exit 0
fi

scripts=("$SCRIPTSDIR"/*)

echo -en "\0prompt\x1fMonitor settings\n"
for ((i=0; i < ${#scripts[@]}; i++)); do
  echo -en "${scripts[$i]}\0icon\x1fmonitor\n"
done
