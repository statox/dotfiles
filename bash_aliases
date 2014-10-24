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

#ls
alias ll='ls -alFh'
alias la='ls -aCF'
alias l='ls -CF'

#clear screen
alias c='clear'

#fast acces to history 
alias h='history'
alias hg='history | grep '

#mkdir: create parents directories + verbose
alias mkdir='mkdir -p -v'

#power management
# shutdown
alias shutnow='sudo shutdown -h now'
# restart
alias restnow='sudo shutdown -r now'

#vim
alias vi='vim'

# apt
alias install='sudo apt-get install'
alias search='apt-cache search'
alias update='sudo apt-get update && sudo apt-get upgrade'

# directories navigation
alias back='cd $OLDPWD'
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'
alias ......='cd ../../../../..'
alias .......='cd ../../../../../..'
alias ........='cd ../../../../../../..'
alias .........='cd ../../../../../../../..'
alias ..........='cd ../../../../../../../../..'


# securisation to avoid unwanted deletions
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'

# quickly output iptables rules
alias ipt='sudo iptables -L'

####################################################
#                   functions                      #
####################################################
#magnifying the cat utility
#/!\ python-pygments needed: sudo apt-get install python-pygments

function cat {
  for file in "$@"
  do
    if [ -f $file ];then
      pygmentize -g $file | more
    else
      echo $file "isn't a file can't display it"
    fi

  done
}


# updates dotfiles via git
function updatedotfiles {
  if [ -d ~/.dotfiles ]; then
    echo "updating dotfiles"
    
    CUR_DIR=$(pwd) 
    cd ~/.dotfiles
    
    git pull origin master
    
    reloadbash
    
    cd $CUR_DIR
    echo "done"
  else
    echo "~/.dotfiles does not exist, please clone the repo github.com/statox/dotfiles"
  fi
}

# push dotfile changes on git
function pushdotfiles {
 
  echo "pushing dotfiles"

  CUR_DIR=$(pwd)
  cd ~/.dotfiles

  git add *
  git commit
  git push origin master

  cd $CUR_DIR
  echo "done"
}

# exectute last command with root privileges
function resudo {
  # get the last command
  LAST=$(fc -ln | tail -n 2 | sed -n 1p)
  # put "sudo " behind it
  CMD="sudo "$LAST
  # prompt what is going to be executed
  echo "$CMD"
  # execution
  $CMD
}

# opens a directory with graphical explorer
#       if no argument is passed, opens current directory
#       else, try to open passed directory
function o {
  if [ -z "$1" ]
  then
    # opened in background, output redirected to /dev/null
    nautilus $(pwd) > /dev/null &
  else
    if [ -d "$1" ]
    then
      nautilus $1 > /dev/null &
    else
      echo "Error: not a directory"
    fi
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

