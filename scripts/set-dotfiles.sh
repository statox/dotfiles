#!/bin/bash
#
# Author: Adrien Fabre (statox)
#
# This script is to use after cloning the repo
# It saves the original dotfiles in ./saved-dotfiles
# and call the make-symlink.sh script to replace them

CUR_DIR=`dirname $0`

# make a save of the current dotfiles
$CUR_DIR/save-dotfiles.sh
echo ""

# creating symlinks 
$CUR_DIR/make-symlinks.sh

# source the .bashrc

if [ -f ~/.bashrc ]
then
    echo "sourcing bashrc"
    source ~/.bashrc
elif [ -f ~/.zshrc ]
then
    echo "sourcing zshrc"
    source ~/.zshrc
fi
