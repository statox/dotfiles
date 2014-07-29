#!/bin/sh
#
# Author: Adrien Fabre (statox)
#
# This script is to use after cloning the repo
# it save the original dotfiles in ./saved-dotfiles
# and call the make-symlink.sh script to replace them


# TODO: check if the directory already exists
mkdir saved-dotfiles


# TODO: replace that by a for loop
mv ~/.bash_aliases saved-dotfiles/
mv ~/.bashrc saved-dotfiles/
mv ~/.bash_logout saved-dotfiles/
mv ~/.motd saved-dotfiles/
mv ~/.vimrc saved-dotfiles/

sh ./make-symlinks.sh
