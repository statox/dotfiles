#!/bin/sh
# 
# Author: Adrien Fabre (statox)
#
# This script makes a copy of dotfiles in home directory

SAVE_DIR=~/.dotfiles/saved-dotfiles
FILES=~/.dotfiles/scripts/files_list


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
  cat ~/.$f > $SAVE_DIR/$f
  rm ~/.$f
done

echo "done"
