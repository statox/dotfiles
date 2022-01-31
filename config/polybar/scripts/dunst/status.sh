#!/usr/bin/env bash

status=$(dunstctl is-paused)
if [ "$status" == "false" ]; then
    # U+1F514
    echo '🔔'
else
    # U+1F515
    echo '🔕'
fi
