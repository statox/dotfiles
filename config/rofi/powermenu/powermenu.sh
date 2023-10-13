#!/usr/bin/env bash

## Author : Aditya Shakya (adi1090x)
## Github : @adi1090x
#
## Rofi   : Power Menu
#
## Available Styles
#
## style-1   style-2   style-3   style-4   style-5
## style-6   style-7   style-8   style-9   style-10

# Current Theme
dir="/home/afabre/.dotfiles/config/rofi/powermenu"
theme='style-5'

# CMDs
uptime=$(uptime -p | sed -e 's/up //g')

# Options (Glyphs from nerd front AurulentSansMono)
lock=''
suspend='⏾'
logout=''
reboot=''
shutdown=''
yes=''
no=''

# Rofi CMD
rofi_cmd() {
	rofi -dmenu \
		-p "Uptime: $uptime" \
		-mesg "Uptime: $uptime" \
		-theme ${dir}/${theme}.rasi
}

# Confirmation CMD
confirm_cmd() {
	rofi -theme-str 'window {location: center; anchor: center; fullscreen: false; width: 350px;}' \
		-theme-str 'mainbox {children: [ "message", "listview" ];}' \
		-theme-str 'listview {columns: 2; lines: 1;}' \
		-theme-str 'element-text {horizontal-align: 0.5;}' \
		-theme-str 'textbox {horizontal-align: 0.5;}' \
		-dmenu \
		-p 'Confirmation' \
		-mesg 'Are you Sure?' \
		-theme ${dir}/${theme}.rasi
}

# Ask for confirmation
confirm_exit() {
	echo -e "$yes\n$no" | confirm_cmd
}

# Pass variables to rofi dmenu
run_rofi() {
	echo -e "$lock\n$suspend\n$logout\n$reboot\n$shutdown" | rofi_cmd
}

# Execute Command
run_cmd() {
    selected="$(confirm_exit)"
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
