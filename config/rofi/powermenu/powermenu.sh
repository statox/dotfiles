#!/usr/bin/env bash

# Power Menu using rofi
# Inspired by https://github.com/adi1090x/rofi

BASEDIR=$(dirname "$0")
theme="$BASEDIR/powermenu.rasi"

# Options (Glyphs from nerd front AurulentSansMono)
lock=''
suspend='⏾'
logout=''
reboot=''
shutdown=''
yes=''
no=''

declare -A messages=(
    ["--shutdown"]="Shutdown"
    ["--reboot"]="Reboot"
    ["--suspend"]="Suspend"
    ["--logout"]="Log out"
)
declare -A commands=(
    ["--shutdown"]="sudo poweroff"
    ["--reboot"]="sudo reboot"
    ["--suspend"]="$HOME/.bin/i3-lock-suspend"
    ["--logout"]="i3-msg exit"
)

rofi_cmd() {
    rofi -dmenu -theme "$theme"
}

# Confirmation CMD
confirm_cmd() {
    local message="$1"
    rofi -theme-str 'window {location: center; anchor: center; fullscreen: false; width: 350px;}' \
        -theme-str 'mainbox {children: [ "message", "listview" ];}' \
        -theme-str 'listview {columns: 2; lines: 1;}' \
        -theme-str 'element-text {horizontal-align: 0.5;}' \
        -theme-str 'textbox {horizontal-align: 0.5;}' \
        -dmenu \
        -p 'Confirmation' \
        -mesg "$message" \
        -theme "$theme"
    }

# Pass variables to rofi dmenu
run_rofi() {
    echo -e "$lock\n$suspend\n$logout\n$reboot\n$shutdown" | rofi_cmd
}

# Execute Command
run_cmd() {
    selected="$(echo -e "$no\n$yes" | confirm_cmd "${messages[$1]}")"
    if [[ "$selected" != "$yes" ]]; then
        exit 0
    fi

    ${commands[$1]}
}

# Actions
chosen="$(run_rofi)"
case ${chosen} in
    "$shutdown")
        run_cmd --shutdown
        ;;
    "$reboot")
        run_cmd --reboot
        ;;
    "$lock")
        i3lock-fancy -gp -- scrot -z -q 1
        ;;
    "$suspend")
        run_cmd --suspend
        ;;
    "$logout")
        run_cmd --logout
        ;;
esac
