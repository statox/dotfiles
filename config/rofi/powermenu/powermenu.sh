#!/usr/bin/env bash

# Power Menu using rofi
# Inspired by https://github.com/adi1090x/rofi

# Current Theme
dir="/home/afabre/.dotfiles/config/rofi/powermenu"
theme='style-5'

# Options (Glyphs from nerd front AurulentSansMono)
lock=''
suspend='⏾'
logout=''
reboot=''
shutdown=''
yes=''
no=''

rofi_cmd() {
	rofi -dmenu \
		-theme ${dir}/${theme}.rasi
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
		-theme ${dir}/${theme}.rasi
}

# Pass variables to rofi dmenu
run_rofi() {
	echo -e "$lock\n$suspend\n$logout\n$reboot\n$shutdown" | rofi_cmd
}

# Execute Command
run_cmd() {
    selected="$(echo -e "$yes\n$no" | confirm_cmd "$1")"
    if [[ "$selected" != "$yes" ]]; then
        exit 0
    fi

    if [[ $1 == '--shutdown' ]]; then
        sudo poweroff
    elif [[ $1 == '--reboot' ]]; then
        sudo reboot
    elif [[ $1 == '--suspend' ]]; then
        "$HOME"/.bin/i3-lock-suspend
    elif [[ $1 == '--logout' ]]; then
        i3-msg exit
    fi
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
