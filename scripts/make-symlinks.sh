#!/bin/sh
#
# Author: Adrien Fabre (statox)
# This script symlinks all the dotfiles of the directory
#

FILES=~/.dotfiles/scripts/files_list
CUR_DIR=$(pwd)

# go to home directory
cd ~

# for each file in the list make a symlink
for f in $(cat $FILES)
do
  ln -s .dotfiles/$f .$f
done

# go back to original directory
cd $CUR_DIR
