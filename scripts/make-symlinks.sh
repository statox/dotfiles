#!/bin/bash
#
# Author: Adrien Fabre (statox)
# This script symlinks all the dotfiles of the directory
#

FILES=~/.dotfiles/scripts/files_list
CUR_DIR=$(pwd)

echo "creating the simlinks"

# go to home directory
cd ~

while read -r line; do
    # ignore empty lines and comments in files_list
    [[ -z $line  ]] && continue
    [[ "$line" =~ ^#.*$  ]] && continue
        echo "${line}"
        ln -s .dotfiles/$line .$line
done < "$FILES"

# go back to original directory
cd $CUR_DIR
