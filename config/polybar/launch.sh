#!/usr/bin/env bash

# Terminate already running bar instances
killall -q polybar

# Wait until the processes have been shut down
while pgrep -u $UID -x polybar >/dev/null; do sleep 1; done

# Launch bar1 and bar2
# echo "---" | tee -a /tmp/polybar_mainscreen.log
# polybar mainscreen >>/tmp/polybar_mainscreen.log 2>&1 &

if type "xrandr"; then
  for m in $(xrandr --query | grep " connected" | cut -d" " -f1); do
      MONITOR=$m polybar --reload main >>/tmp/polybar_main_$MONITOR.log 2>&1 &
  done
else
  polybar --reload main &
fi

echo "Bars launched..."
