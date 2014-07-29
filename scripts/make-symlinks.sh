#!/bin/sh
#
# Author: Adrien Fabre (statox)
# This script symlinks all the dotfiles of the directory
#
# TODO: replace all the lines by a for loop

cd ~

ln -s .dotfiles/bashrc .bashrc
ln -s .dotfiles/bash_aliases .bash_aliases
ln -s .dotfiles/bash_logout .bash_logout
ln -s .dotfiles/motd .motd
ln -s .dotfiles/vimrc .vimrc
