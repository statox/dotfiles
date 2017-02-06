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

#clear screen
alias c='clear'

#fast acces to history
alias h='hg'
#grep several words in the history
function hg {
    cmd="history"

    # append as many grep as needed
    for arg in $@
    do
        cmd=$cmd" | grep "$arg
    done

    echo $cmd
    eval "$cmd"
}

#mkdir: create parents directories + verbose
alias mkdir='mkdir -p -v'

#power management
# shutdown
alias shutnow='sudo shutdown -h now'
# restart
alias restnow='sudo shutdown -r now'

#vim
alias v='vim'

# apt
alias install='sudo apt-get install'
alias search='apt-cache search'
alias update='sudo apt-get update'
alias upgrade='sudo apt-get upgrade'

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

# quickly output iptables rules
alias ipt='sudo iptables -L'

# show hubic client status
alias hubicstatus='watch -n 0,1 hubic status'

# make df human readable
alias df='df -h'

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

# restore vim with a session file
alias lvim='vim -S ~/Session.vim'

# Get debian version codename
alias debianversion='lsb_release -a'
####################################################
#                   functions                      #
####################################################
#magnifying the cat utility
#/!\ python-pygments needed: sudo apt-get install python-pygments

function ccat {
  for file in "$@"
  do
    if [ -f $file ];then
      pygmentize -g $file
    else
      echo $file "isn't a file can't display it"
    fi

  done
}

# exectute last command with root privileges
function resudo {
    # get the last command
    # the behavior of sed seems not to be the same in bash and zsh
    # so we adapt with $DELIM
    if [[ $SHELL == *"zsh"* ]]; then
        DELIM=2p
    else
        DELIM=1p
    fi

    LAST=$(fc -ln | tail -n 2 | sed -n $DELIM)
    # put "sudo " behind it
    CMD="sudo "$LAST
    # prompt what is going to be executed
    echo "$CMD"
    # execution
    eval $CMD
}

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

# prompt files after cd
function cl {
  cd $1;
  ls;
}

# prompt all files after cd
function cla {
  cd $1;
  la;
}

# opens graphical explorer after cd
function co {
  cd $1;
  o $1;
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
