#!/bin/sh
set -eu

IFS='|' read -r type message || true

case "$type" in
    waiting) urgency=low; icon=dialog-question ;;
    done)    urgency=low; icon=dialog-ok ;;
    *)       urgency=low; icon=dialog-information ;;
esac

echo "[broker] notify: type=${type} message=${message}" >&2

# socat tears down this process (and anything still attached to its session)
# as soon as the client closes the connection, which happens right after it
# sends its one line. paplay usually finishes before that race is lost, but
# notify-send's D-Bus round trip often doesn't. setsid detaches the actual
# work into its own session so it survives past this process's teardown.
# shellcheck disable=SC2016
setsid sh -c '
    paplay /claude-assets/bell.wav >/dev/null 2>&1 || true
    notify-send "$1" -a Claude -u "$2" -i "$3" -t 1500 || true
' -- "$message" "$urgency" "$icon" </dev/null >/dev/null 2>&1 &
