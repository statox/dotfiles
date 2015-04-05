#!/bin/bash
#
# Author: Adrien Fabre (statox)
#
# This script makes a copy of dotfiles in home directory

SAVE_DIR=~/.dotfiles/saved-dotfiles
FILES=~/.dotfiles/scripts/files_list

DATE=$(date +%y%m%d_%H%M%S)

SAVE_DIR=$SAVE_DIR/$DATE

echo "saving current dotfiles"

if [ ! -d $SAVE_DIR ]; then
    echo "Creating saving directory: $SAVE_DIR"
    mkdir -p $SAVE_DIR
else
    echo "Saving directory already exists: $SAVE_DIR"
fi


while read -r line; do
# ignore empty lines and comments in files_list
[[ -z $line  ]] && continue
[[ "$line" =~ ^#.*$  ]] && continue
    if [ -d ~/.$line ]; then
        echo "directory ${line}"
        cp -Lr ~/.$line $SAVE_DIR/$line
        rm -rf ~/.$line
    elif [ -f ~/.$line ]; then
        echo "file ${line}"
        cat ~/.$line > $SAVE_DIR/$line
        rm -f ~/.$line
    else
        echo "not found ${line}"
    fi
done < "$FILES"
