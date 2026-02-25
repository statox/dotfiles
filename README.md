# Dotfiles

This repo is used to save and sync my dotfiles between different machines.
When cloning and executing the scripts for the first time, the current dotfiles are saved and replaced by symlinks to the ones in the repo.

The instructions below are a reminder on how to use the scripts.

## Installation

### Clone the repo

On a new system clone the repo under ~/.dotfiles

    git clone https://github.com:statox/dotfiles ~/.dotfiles

It is possible to add to $PATH the path to the scripts.

    export PATH=$PATH:path/to/.dotfiles/scripts

### Configure the git hooks

We have a [`post-merge`](./githooks/files/post-merge) git hook which updates nvim plugins if the lockfile of nvim plugins changed (`lazy-lock.json` when using [lazy.nvim](https://github.com/folke/lazy.nvim)).

When cloning the repo set it up by running `./githooks/setup.sh`

### Select which files to manage

In `./scripts/files_list` 

Select the files you want to simlink and keep under this repo. Not wanted files can be commented with "#"

### Execute the script

Execute the script

    ./scripts/set-dotfiles.sh

### And voila

The dotfiles in your home directory are now symlinked to the files in ~/.dotfiles!
Originals dotfiles aren't deleted they are copied under ~/.dotfiles/saved-dotfiles
