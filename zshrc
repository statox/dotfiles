#------------------------------------------------------------------------------
#   Zsh configuration file
#------------------------------------------------------------------------------


#------------------------------------------------------------------------------
#   plugins
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# IMPORTANT: zsh-syntax-highlighting MUST be placed in last position
plugins=(bgnotify colored-man cp extract git git-prompt tmux z zsh-syntax-highlighting)


#------------------------------------------------------------------------------
#   miscelanious zsh configuration

# line added by zsh auto config
# perform cd when something which is not a command is entered
setopt autocd
# beep on error in zle
setopt beep
# report the status of background jobs immediately
setopt notify
# sanity check for 'rm *'
setopt rm_star_wait
# allows Bash style comments on command line
setopt interactivecomments
# spelling corrector
setopt correct_all

setopt extendedglob nomatch

# fast acces to man page with <Esc-h> while typping a command
autoload run-help


#------------------------------------------------------------------------------
#   Variables definitions

# set vim as default editor
export VISUAL=vim
export EDITOR=$VISUAL

# User configuration
export PATH="/usr/local/bin:/usr/bin:/bin:/usr/local/games:/usr/games"
export MANPATH="/usr/local/man:$MANPATH"

# Tmux plugin need it to start Tmux at connexion
export ZSH_TMUX_AUTOSTART=true

# Path to oh-my-zsh installation.
export ZSH=~/.oh-my-zsh


#------------------------------------------------------------------------------
#   theme
# colorscheme solarized defined in ~/Xresources for xterm


#------------------------------------------------------------------------------
#   aliases

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi


#------------------------------------------------------------------------------
#   completion

# enable completion
autoload -Uz compinit && compinit
zmodload zsh/complist

# added by zsh auto install
zstyle :compinstall filename '/home/adrien/.zshrc'

# allow autocomplet on zshrc aliases and selection of suggestions
zstyle ':completion:*' menu select
setopt completealiases

# pick item but stay in the menu
# It works but output an error message at zsh start i dont know why
bindkey -M menuselect "+" accept-and-menu-complete

# command auto-correction.
ENABLE_CORRECTION="true"

# display red dots whilst waiting for completion.
COMPLETION_WAITING_DOTS="true"


#------------------------------------------------------------------------------
#   History

# append entries in history files instead of deleting the existing file
setopt inc_append_history
# append timestamp to history
setopt extended_history
# don't put duplicate lines in the history.
setopt hist_ignore_dups
# don't put lines beginning with space character
setopt hist_ignore_space
# beep when trying to acces an unexisting entry in history
setopt hist_beep

#command execution timestamp shown in the history command output.
# The optional three formats: "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
HIST_STAMPS="dd/mm/yyyy"

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=100000
HISTFILESIZE=200000

# Lines configured by zsh-newuser-install
HISTFILE=~/.histfile
SAVEHIST=100000


#------------------------------------------------------------------------------
#   key binding

# go to remember:
#
#   ^  := ctrl
#   ^[ := esc

bindkey -v

# Arrows for reverse search
bindkey '^[[A' up-line-or-search
bindkey '^[[B' down-line-or-search


#------------------------------------------------------------------------------
#   sourcing oh my zsh
source $ZSH/oh-my-zsh.sh


#------------------------------------------------------------------------------
#   Fancy prompt :)
autoload -U promptinit
autoload -U colors && colors
promptinit


PROMPT="\
%{$fg[blue]%}%n\
%{$reset_color%}@\
%{$fg[green]%}%m\
%{$reset_color%} "

# the plugin git-prompt already set the first part of RPROMPT
RPROMPT=$RPROMPT"\
%{$fg[green]%}%(?..[%?])\
%{$fg_no_bold[yellow]%}%3~\
%{$reset_color%}"

# set dircolors to follow solarized colors
if [ -f ~/.dircolors.256dark ]
then
    eval `dircolors ~/.dircolors.256dark`
fi
