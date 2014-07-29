#!/bin/sh
#
# Author: Adrien Fabre (statox)
# This script symlinks all the dotfiles of the directory
#
# TODO: replace all the lines by a for loop


ln -s bashrc ~/.bashrc
ln -s bash_aliases ~/.bash_aliases
ln -s bash_logout ~/.bash_logout
ln -s motd ~/.motd
ln -s vimrc ~/.vimrc
