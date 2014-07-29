# ~/.bash_aliases
#
# Author: Adrien Fabre
#
# This file contains useful aliases and functions
# It must be called in ~/basrc


####################################################
#                   aliases                        #
####################################################

# reload .bashrc (after modifying it)
alias reloadbashrc='source ~/.bashrc'

#ls
alias ll='ls -alFh'
alias la='ls -a'
alias l='ls -CF'

#mkdir: create parents directories + verbose
alias mkdir='mkdir -p -v'

#power management
# shutdown
alias shutnow='sudo shutdown -h now'
# restart
alias restnow='sudo shutdown -r now'

#vim
alias vi='vim'

# IDEs
alias codeblocks='sudo codeblocks'
alias adt='/home/adrien/developpement_android/adt-bundle-linux-x86-20140702/eclipse/eclipse'

# ssh
# voir /home/adrien/.ssh/config pour les alias ssh
alias choam='ssh choam'
alias efrei='ssh darnassus'
alias koala='ssh koala'
alias poney='ssh poney'

# apt
alias install='sudo apt-get install'
alias search='apt-cache search'
alias update='sudo apt-get update && apt-get upgrade'

# directories navigation
alias back='cd $OLDPWD'
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'

# securisation to avoid unwanted deletions
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'

# colorize cat
#/!\ python-pygments needed: sudo apt-get install python-pygments
alias ccat='pygmentize -g'

####################################################
#                   functions                      #
####################################################

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

# mount remote directory via ssh
function seed {

  if [ "$1" = mount ] || [ "$1" = m ]; then 
    echo "mounting ~/seedbox"
    sshfs -o reconnect -C -p 22 koala:/home/seed/seedstatox ~/seedbox
  elif [ "$1" = unmount ] || [ "$1" = u ]; then
    echo "unmounting ~/seedbox"
    fusermount -u ~/seedbox
  elif [ -z "$1" ]; then
    echo "argument vide"
  else
    echo "Error: invalid argument $1"
    echo "usage: seed mount|m|unmount|u"
  fi
  
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
