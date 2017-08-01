# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples
# to set bash as default shell interpreter, use this:
# chsh -s $(which bash)

# If not running interactively, don't do anything
[ -z "$PS1" ] && return


#------------------------------------------------------------
#       TMUX

if which tmux >/dev/null 2>&1; then

    # try to attach an existing session, if no session is started, start a new session
    test -z ${TMUX} && (tmux attach || tmux new)

    # when quitting tmux, try to attach
    #while test -z ${TMUX}; do
        #tmux attach || break
    #done
fi

#------------------------------------------------------------
#            History

# don't put duplicate lines in the history. See bash(1) for more options
# ... or force ignoredups and ignorespace
HISTCONTROL=ignoredups:ignorespace

# adding date and time in history file
HISTTIMEFORMAT='%F %T '

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=100000
HISTFILESIZE=200000

# multilines commands are reformated to single line command in history file
shopt -s cmdhist

# By default, Bash only records a session to the .bash_history file on disk when the session terminates. 
# on force a sauvegarder a chaque commande histoire de pas perdre en cas de sessions qui plante
PROMPT_COMMAND='history -a'

#------------------------------------------------------------
#         Fancy prompt :)

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "$debian_chroot" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
    xterm-color) color_prompt=yes;;
esac

# uncomment for a colored prompt, if the terminal has the capability; turned
# off by default to not distract the user: the focus in a terminal window
# should be on the output of commands, not on the prompt
force_color_prompt=yes

if [ -n "$force_color_prompt" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
    # We have color support; assume it's compliant with Ecma-48
    # (ISO/IEC-6429). (Lack of such support is extremely rare, and such
    # a case would tend to support setf rather than setaf.)
    color_prompt=yes
    else
    color_prompt=
    fi
fi


if [ "$color_prompt" = yes ]; then

    # shorten the pwd
    PS1_PWD_MAX=15
    __pwd_ps1() { echo -n $PWD | sed -e "s|${HOME}|~|" -e "s|\(/[^/]*/\).*\(/.\{${PS1_PWD_MAX}\}\)|\1...\2|";  }

    GIT_PS1_SHOWDIRTYSTATE=1

    PS1='\n\n\
\[\e[m\]\$\
\[\033[34m\]\u\
\[\e[m\]@\
\[\033[32m\]\H\
\[\033[37m\] \
\[\033[33m\]$(__pwd_ps1) \
\[\033[35m\]$(__git_ps1 "[%s]") \
\[\e[m\]'

else
    PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
fi
unset color_prompt force_color_prompt

# If this is an xterm set the title to user@host:dir
case "$TERM" in
xterm*|rxvt*)
    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
    ;;
*)
    ;;
esac

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    alias dir='dir --color=auto'
    alias vdir='vdir --color=auto'

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

#------------------------------------------------------------
#         aliases


# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.

if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if [ -f /etc/bash_completion ] && ! shopt -oq posix; then
    . /etc/bash_completion
fi


#------------------------------------------------------------
#       Variables definitions

# set vim as default editor
export VISUAL=vim
export EDITOR=$VISUAL


