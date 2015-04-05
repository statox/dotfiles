#dotfiles

This repo is used to save and sync my dotfiles between differents machines.
When cloning and executing the scripts for the first time, the current dotfiles are saved and remplaced by symlinks to the ones in the repo.

The instructions belows are a reminder on how to use the scripts.

## Installation

### Clone the repo
On a new system clone the repo under ~/.dotfiles

`git clone https://github.com:statox/dotfiles ~/.dotfiles`

### Select which files to manage
In `~/.dotfiles/scripts/files_list` 

Select the files you want to simlink and keep under this repo. Not wanted files can be commented with "#"

### Execute the script
Execute scripts/set-dotfiles.sh

`./.dotfiles/scripts/set-dotfiles.sh`

### And voila
The dotfiles in your ~/  are now symlinked to the files in ~/.dotfiles!

Originals dotfiles aren't deleted they are copied under ~/.dotfiles/saved-dotfiles
