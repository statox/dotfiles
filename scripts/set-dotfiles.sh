#!/bin/bash
#
# Author: Adrien Fabre (statox)
#
# This script is to use after cloning the repo
# It saves the original dotfiles in ./saved-dotfiles
# and symlinks the files to replace them


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

        if [ -d ~/."$line" ]; then
            echo "directory ${line}"
            cp -Lr ~/."$line" "$SAVE_DIR"/"$line"
            rm -rf ~/."$line"
        elif [ -f ~/."$line" ]; then
            echo "file ${line}"
            cat ~/."$line" > "$SAVE_DIR"/"$line"
            rm -f ~/."$line"
        else
            echo "not found ${line}"
        fi
    done < "$FILES"
}

additional-installs() {
    echo "Installing git bash completion file"
    curl -fLo ~/.git-completion.bash https://raw.githubusercontent.com/git/git/master/contrib/completion/git-completion.bash
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

# additional installations
additional-installs
echo ""
