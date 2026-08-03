#!/usr/bin/env bash

API_URL="https://api.statox.fr/homeTracker/getSensorsDataForDashboard"
ERROR_ICON=$''
ARROW_UP=$''
ARROW_DOWN=$''
ARROW_FLAT=$''

SENSOR="$1"

case "$SENSOR" in
    salon)
        ;;
    jardiniere)
        ;;
    *)
        echo "Usage: $0 <salon|jardiniere>" >&2
        exit 1
        ;;
esac

CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/polybar"
CACHE_FILE="$CACHE_DIR/home-tracker.json"
CACHE_TTL=600
MODE_FILE="$CACHE_DIR/home-tracker-mode-$SENSOR"

mkdir -p "$CACHE_DIR"

if [ "$2" = "--toggle" ]; then
    mode="current"
    [ -f "$MODE_FILE" ] && mode="$(cat "$MODE_FILE")"
    if [ "$mode" = "diff" ]; then
        echo "current" > "$MODE_FILE"
    else
        echo "diff" > "$MODE_FILE"
    fi
    exit 0
fi

data=""
if [ -f "$CACHE_FILE" ]; then
    cache_age=$(( $(date +%s) - $(stat -c %Y "$CACHE_FILE") ))
    if [ "$cache_age" -lt "$CACHE_TTL" ]; then
        data="$(cat "$CACHE_FILE")"
    fi
fi

if [ -z "$data" ]; then
    data="$(curl -s -m 5 -A "polybar-home-tracker/$(hostname)" "$API_URL")"
    if [ -n "$data" ]; then
        echo "$data" > "$CACHE_FILE"
    elif [ -f "$CACHE_FILE" ]; then
        data="$(cat "$CACHE_FILE")"
    fi
fi

if [ -z "$data" ]; then
    echo "$ERROR_ICON --"
    exit 0
fi

now="$(echo "$data" | jq -r --arg name "$SENSOR" '.sensors[] | select(.sensorName == $name) | .lastLogData.tempCelsius')"
hour_ago="$(echo "$data" | jq -r --arg name "$SENSOR" '.sensors[] | select(.sensorName == $name) | .oneHourAgoLogData.tempCelsius')"
temp_offset="$(echo "$data" | jq -r --arg name "$SENSOR" '.sensors[] | select(.sensorName == $name) | .tempOffset')"

if [ -z "$now" ] || [ "$now" = "null" ]; then
    echo "$ERROR_ICON --"
    exit 0
fi

if [ -n "$temp_offset" ] && [ "$temp_offset" != "null" ]; then
    now="$(awk -v v="$now" -v o="$temp_offset" 'BEGIN { print v + o }')"
    [ -n "$hour_ago" ] && [ "$hour_ago" != "null" ] && hour_ago="$(awk -v v="$hour_ago" -v o="$temp_offset" 'BEGIN { print v + o }')"
fi

mode="current"
[ -f "$MODE_FILE" ] && mode="$(cat "$MODE_FILE")"

if [ "$mode" = "diff" ]; then
    day_ago="$(echo "$data" | jq -r --arg name "$SENSOR" '.sensors[] | select(.sensorName == $name) | .oneDayAgoLogData.tempCelsius')"
    if [ -z "$day_ago" ] || [ "$day_ago" = "null" ]; then
        echo "$ERROR_ICON --"
        exit 0
    fi
    if [ -n "$temp_offset" ] && [ "$temp_offset" != "null" ]; then
        day_ago="$(awk -v v="$day_ago" -v o="$temp_offset" 'BEGIN { print v + o }')"
    fi
    printf "%s° (1d) \n" "$(awk -v now="$now" -v prev="$day_ago" 'BEGIN { printf "%+.1f", now - prev }')"
    exit 0
fi

arrow="$ARROW_FLAT"
if [ -n "$hour_ago" ] && [ "$hour_ago" != "null" ]; then
    arrow="$(awk -v now="$now" -v prev="$hour_ago" 'BEGIN {
        diff = now - prev
        if (diff > 0.2) print "'"$ARROW_UP"'"
        else if (diff < -0.2) print "'"$ARROW_DOWN"'"
        else print "'"$ARROW_FLAT"'"
    }')"
fi

printf "%s° %s \n" "$(printf "%.1f" "$now")" "$arrow"
