#!/bin/bash
# 
# Author: Adrien Fabre (statox)
#
# This script makes a copy of dotfiles in home directory

SAVE_DIR=~/.dotfiles/saved-dotfiles
FILES=~/.dotfiles/scripts/files_list

DATE=$(date +%y%m%d_%H%M%S)

SAVE_DIR=$SAVE_DIR/$DATE

if [ ! -d $SAVE_DIR ]; then
    echo "create dir $SAVE_DIR"
    mkdir -p $SAVE_DIR
else
    echo "$SAVE_DIR already exists"
fi

echo "saving files"

for f in $(cat $FILES)
do
  echo "   " $f
  if [ -d ~/.$f ]; then
    echo "directory"
    cp -Lr ~/.$f $SAVE_DIR/$f
    rm -rf ~/.$f
  elif [ -f ~/.$f ]; then
    echo "file"
    cat ~/.$f > $SAVE_DIR/$f
    rm -f ~/.$f
  else
    echo "not found"
  fi
  done

echo "done"
