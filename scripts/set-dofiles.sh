#!/bin/sh
#
# Author: Adrien Fabre (statox)
#
# This script is to use after cloning the repo
# it save the original dotfiles in ./saved-dotfiles
# and call the make-symlink.sh script to replace them


# make a save of the current dotfiles
sh ./save-dotfiles.sh

# creating symlinks 
sh ./make-symlinks.sh
