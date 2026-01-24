#!/bin/bash

# Use this script after cloning the repo
# It saves the original dotfiles in ./saved-dotfiles
# and symlinks the files to replace them

set -e

# Symlinks all the dotfiles of the home directory to the saving dir
make-symlinks() {
    echo "## Create symlinks"

    while read -r line; do
        # ignore empty lines and comments in files_list
        [[ -z $line  ]] && continue
        [[ "$line" =~ ^#.*$  ]] && continue

        echo "  ${line}"
        dest_path="$HOME/.$line"
        containing_directory=$(dirname $dest_path)
        origin_path=$(readlink -m "$CUR_DIR/../$line")

        mkdir -p $containing_directory
        ln -s "$origin_path" "$dest_path"
    done < "$FILES"
}

# Makes a copy of dotfiles in home directory
save-dotfiles() {

    DATE=$(date +%y%m%d_%H%M%S)

    SAVE_DIR=$SAVE_DIR/$DATE

    echo "## Save current dotfiles"

    if [ ! -d "$SAVE_DIR" ]; then
        echo "Creating saving directory: $SAVE_DIR"
        mkdir -p "$SAVE_DIR"
    else
        echo "Saving directory already exists: $SAVE_DIR"
    fi


    while read -r line; do
        # ignore empty lines and comments in files_list
        [[ -z $line  ]] && continue
        [[ "$line" =~ ^#.*$  ]] && continue

        # Create the parent directory if needed
        # (e.g to save `config/dunst` we need to create `config/` first)
        containing_directory="$SAVE_DIR/$(dirname $line)"
        mkdir -p "$containing_directory"

        if [ -d ~/."$line" ]; then
            echo "directory ${line}"
            cp -Lr ~/."$line" "$SAVE_DIR"/"$line"
            rm -rf ~/."$line"
        elif [ -f ~/."$line" ]; then
            echo "file ${line}"
            cat ~/."$line" > "$SAVE_DIR"/"$line"
            rm -f ~/."$line"
        else
            echo "not found can't save  ${line}"
        fi
    done < "$FILES"
}

# Get the files needed to work
CUR_DIR=$(cd  $(dirname $0);pwd)
SAVE_DIR=$CUR_DIR/../saved-dotfiles
FILES=$CUR_DIR/files_list

# make a save of the current dotfiles
save-dotfiles
echo ""

# creating symlinks
make-symlinks
echo ""
