#!/bin/bash
#
# Author: Adrien Fabre (statox)
#
# This script is to use after cloning the repo
# It saves the original dotfiles in ./saved-dotfiles
# and symlinks the files to replace them


# Symlinks all the dotfiles of the home directory to the saving dir
make-symlinks() {
    echo "files list: $FILES"
    echo "creating the simlinks"

    # go to home directory
    cd ~

    while read -r line; do
        # ignore empty lines and comments in files_list
        [[ -z $line  ]] && continue
        [[ "$line" =~ ^#.*$  ]] && continue
            echo "${line}"
            ln -s $CUR_DIR/../$line .$line
    done < "$FILES"
}

# Makes a copy of dotfiles in home directory
save-dotfiles() {

    DATE=$(date +%y%m%d_%H%M%S)

    SAVE_DIR=$SAVE_DIR/$DATE

    echo "saving current dotfiles"

    if [ ! -d $SAVE_DIR ]; then
        echo "Creating saving directory: $SAVE_DIR"
        mkdir -p $SAVE_DIR
    else
        echo "Saving directory already exists: $SAVE_DIR"
    fi


    while read -r line; do
    # ignore empty lines and comments in files_list
    [[ -z $line  ]] && continue
    [[ "$line" =~ ^#.*$  ]] && continue
        if [ -d ~/.$line ]; then
            echo "directory ${line}"
            cp -Lr ~/.$line $SAVE_DIR/$line
            rm -rf ~/.$line
        elif [ -f ~/.$line ]; then
            echo "file ${line}"
            cat ~/.$line > $SAVE_DIR/$line
            rm -f ~/.$line
        else
            echo "not found ${line}"
        fi
    done < "$FILES"
}

additional-installs() {
    echo "Configuring VimPlug"
    curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim 
    vim +PlugInstall +qall &>/dev/null &
    echo "Vim configured"
}

# Get the files needed to work
CUR_DIR=`cd  $(dirname $0);pwd`
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

# source the shell configuration file
if [ -f ~/.bashrc ]
then
    echo "sourcing bashrc"
    source ~/.bashrc
elif [ -f ~/.zshrc ]
then
    echo "sourcing zshrc"
    source ~/.zshrc
fi

