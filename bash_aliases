# ~/.bash_aliases
#
# Author: Adrien Fabre
#
# This file contains useful aliases and functions
# It must be called in ~/basrc

####################################################
#                 local  aliases                   #
####################################################

# Aliases used only in this machine (not synched with git)

if [ -f ~/.bash_aliases_local ]; then
    . ~/.bash_aliases_local
fi

####################################################
#                   aliases                        #
####################################################

# reload .bashrc (after modifying it)
alias reloadbashrc='source ~/.bashrc'
alias reloadzshrc='source ~/.zshrc'

#ls
alias ldot='ls -d .*'
alias ll='ls -AlFh'
alias la='ls -ACF'
alias l='ls -CF'

#git
alias g='git'
alias gs='git status'
alias gd='git diff'
alias gdc='git diff --cached'
alias ga='git add'
alias gp='git push'
alias gc='git commit'
alias gl='git pull --rebase'
alias glg='git log'
alias glgs='git log --show-signature'
alias glgp='git log -p'
alias gco='git checkout'

alias gcoi='git checkout $(git branch | fzf)'
alias gdi='git diff $(git status --porcelain | sed "s/\w //" | fzf)'
# if command -v fzf > /dev/null 2>&1; then
    # alias gcoi='git checkout $(git branch | fzf)'
    # alias gdi='git diff $(git status --porcelain | sed "s/\w //" | fzf)'
# else
    # alias gcoi='echo "fzf not found no aliases"'
    # alias gdi='echo "fzf not found no aliases"'
# fi

alias glgi='fzf-show-commits'
# Taken from fshow - git commit browser on https://github.com/junegunn/fzf/wiki/examples#git
fzf-show-commits() {
  git log --graph --color=always \
      --format="%C(auto)%h%d %s %C(black)%C(bold)%cr" "$@" |
  fzf --ansi --no-sort --reverse --tiebreak=index --bind=ctrl-s:toggle-sort \
      --bind "ctrl-m:execute:
                (grep -o '[a-f0-9]\{7\}' | head -1 |
                xargs -I % sh -c 'git show --color=always % | less -R') << 'FZF-EOF'
                {}
FZF-EOF"
}

# Ag the silver searcher
alias agw='ag --word-regex'

# node repl
alias ni='node -i'
# npm
alias npmr='npm run'

alias ts='date +"%s"'
alias ts2date='timestamp2date'
function timestamp2date {
    echo $(date -d @$1)
}

# Restart polybar
if [ -f ~/.config/polybar/launch.sh ]; then
    alias polystart='source ~/.config/polybar/launch.sh &'
fi

# Add git completion to aliases if we are in bash
# (zsh already has that by default)
if [[ $SHELL =~ 'bash' && -f ~/.git-completion.bash ]]; then
    source ~/.git-completion.bash

    __git_complete g __git_main
    __git_complete gs _git_status
    __git_complete gd _git_diff
    __git_complete ga _git_add
    __git_complete gp _git_pull
    __git_complete gP _git_push
    __git_complete gc _git_commit
    __git_complete gl _git_log
    __git_complete gco _git_checkout
fi

#mkdir: create parents directories + verbose
alias mkdir='mkdir -p -v'

#power management
# shutdown
alias shutnow='sudo shutdown -h now'
# restart
alias restnow='sudo shutdown -r now'

#vim
alias v='nvim'
alias vi='vim'
alias n='nvim'
alias vim='nvim'

# directories navigation
alias back='cd $OLDPWD'
alias ..='cd ../'
alias ...='cd ../../'
alias ....='cd ../../../'
alias .....='cd ../../../../'
alias ......='cd ../../../../../'
alias .......='cd ../../../../../../'
alias ........='cd ../../../../../../../'
alias .........='cd ../../../../../../../../'
alias ..........='cd ../../../../../../../../../'

# directories navigation with z + fzf
# TODO add check for existance of the commands
alias zf='z $(z | fzf)'

# quickping with human readable timestamp
function p {
    ping -vD 8.8.8.8 | while read row
    do
        if [[ $row == \[*\]*  ]]; then
            DATE=$(date +"%d-%m-%y %T" -d @$(echo $row | grep -Eo "[0-9]{10}.[0-9]{6}"))
            sed -r -e "s/[0-9]{10}.[0-9]{6}/$DATE/g" -e 's/icmp.req.//g' <<< "$row"
        fi
    done
}

alias p1='ping 1.1.1.1'

# restore vim with a session file
alias lvim='vim -S ~/Session.vim'

# Get debian version codename
alias debianversion='lsb_release -a'

# Node
# Start node with debugging
alias noded='node --inspect-brk'

# Sudo
# https://askubuntu.com/a/22043
# alias sudo='sudo '
# Use sode with the current $PATH (useful when using docker)
alias sudop='sudo env PATH=$PATH'

# Docker
# Use docker with sudo and $PATH set
alias sdocker='sudo env PATH=$PATH docker'
alias sdocker-compose='sudo env PATH=$PATH docker-compose'

alias ansible-playbook='ansiblePlaybookDebug'
function ansiblePlaybookDebug {
    export ANSIBLE_STDOUT_CALLBACK=default
    echo -n "$@" | grep -q -- "-v" && export ANSIBLE_STDOUT_CALLBACK=yaml

    'ansible-playbook' "$@"
}

####################################################
#                   functions                      #
####################################################
# Open files or directory in GUI application
# (xdg-open is better than gnome-open because it is desktop agnostic)
function o {
    # If no parameter is passed open current folder
    if [ $# -eq 0 ] || [ -z $@ ]; then
        xdg-open ./
    else
        xdg-open $@ 
    fi
}

# function Extract for common file formats
function extract {
if [ -z "$1" ]; then
  # display usage if no parameters given
  echo "Usage: extract <path/file_name>.<zip|rar|bz2|gz|tar|tbz2|tgz|Z|7z|xz|ex|tar.bz2|tar.gz|tar.xz>"
else
  if [ -f $1 ] ; then
     # creation of the folder where to extract the files
     #NAME=${1%.*}
     #mkdir $NAME && cd $NAME
     # extraction
     case $1 in
        *.tar.bz2) tar xvjf ./$1 ;;
        *.tar.gz) tar xvzf ./$1 ;;
        *.tar.xz) tar xvJf ./$1 ;;
        *.lzma) unlzma ./$1 ;;
        *.bz2) bunzip2 ./$1 ;;
        *.rar) unrar x -ad ./$1 ;;
        *.gz) gunzip ./$1 ;;
        *.tar) tar xvf ./$1 ;;
        *.tbz2) tar xvjf ./$1 ;;
        *.tgz) tar xvzf ./$1 ;;
        *.zip) unzip ./$1 ;;
        *.Z) uncompress ./$1 ;;
        *.7z) 7z x ./$1 ;;
        *.xz) unxz ./$1 ;;
        *.exe) cabextract ./$1 ;;
        *) echo "extract: '$1' - unknown archive method" ;;
     esac
  else
     echo "$1 - file does not exist"
  fi
fi
}

# Creates an archive (*.tar.gz) from given directory.
function maketar { tar cvzf "${1%%/}.tar.gz"  "${1%%/}/"; }
# Create a ZIP archive of a file or folder.
function makezip { zip -r "${1%%/}.zip" "$1" ; }

# Create an archive of a given format from a given file or directory
function archive {

  if [ ! -d "$2" ] && [ ! -f "$2" ];then
    echo "not a file or directory"
    echo "Usage: archive [format] [path/to/file/or/directory]"
    return -1
  fi

  case "$1" in
    tar.gz)   tar cvzf "${2%%/}.tar.gz"  "${2%%/}/";;
    zip)      zip -r "${2%%/}.zip" "$2" ;;
    gz|gzip)  cat $2 | gzip > $2.gz;;
    *)    echo "wrong archive type" 
          echo "Usage: archive [format] [path/to/file/or/directory]";;
  esac
}


# looping through a command
loop() {
    echo Starting: "$@"
    while true; do
        eval $(printf "%q " "$@")
        sleep 1;
    done
}

loopd() {

    CMD=""
    DELAY=1
    re='^[0-9]+$'

    # get the command and skip the first argument if it is a number
    if [[ $1 =~ $re  ]] ; then
        DELAY=$1
        CMD=$2
        for i in "${@:3}"; do
            CMD="$CMD $i"
        done
    else
        CMD=$@
    fi

    echo Starting: "$CMD"
    echo Delay: "$DELAY"
    while true; do
        eval $(printf "%q " "$CMD")
        sleep $DELAY;
    done
}
