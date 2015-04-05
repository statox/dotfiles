#!/bin/bash
#
# Author: Adrien Fabre (statox)
#
# This script is to use after cloning the repo
# it save the original dotfiles in ./saved-dotfiles
# and call the make-symlink.sh script to replace them


# make a save of the current dotfiles
./save-dotfiles.sh
echo ""

# creating symlinks 
./make-symlinks.sh

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
