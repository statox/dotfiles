#!/bin/sh
# 
# Author: Adrien Fabre (statox)
#
# This script makes a copy of dotfiles in home directory

SAVE_DIR=~/.dotfiles/saved-dotfiles

if [ ! -d $SAVE_DIR ]; then
    echo "create dir $SAVE_DIR"
    mkdir -p $SAVE_DIR
else
    echo "$SAVE_DIR already exists"
fi

echo "saving files"
cat ~/.bashrc > $SAVE_DIR/bashrc
cat ~/.bash_aliases > $SAVE_DIR/bash_aliases
cat ~/.bash_logout > $SAVE_DIR/bash_logout
cat ~/.motd > $SAVE_DIR/motd
cat ~/.vimrc > $SAVE_DIR/vimrc

echo "done"
