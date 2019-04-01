#~/.zshrc
# vim:fdm=marker

# Plugins {{{
    # IMPORTANT: zsh-syntax-highlighting MUST be placed in last position
    plugins=(bgnotify colored-man cp docker docker-compose extract git git-prompt npm tmux z zsh-syntax-highlighting)
# }}}
# Miscelanious zsh configuration {{{
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
# }}}
# Vim like keybinding {{{
    # Use Vi-like keybinding
    set -o vi

    # # Remove mode switching delay.
    # KEYTIMEOUT=5

    # # Change cursor shape for different vi modes.
    # function zle-keymap-select {
      # if [[ ${KEYMAP} == vicmd ]] ||
         # [[ $1 = 'block' ]]; then
        # echo -ne '\e[1 q'

      # elif [[ ${KEYMAP} == main ]] ||
           # [[ ${KEYMAP} == viins ]] ||
           # [[ ${KEYMAP} = '' ]] ||
           # [[ $1 = 'beam' ]]; then
        # echo -ne '\e[5 q'
      # fi
    # }
    # zle -N zle-keymap-select

    # Use beam shape cursor on startup.
    echo -ne '\e[5 q'

    # Fix cursor shape when starting a command {{{
        _fix_cursor() {
           echo -ne '\e[5 q'
        }
        precmd_functions+=(_fix_cursor)
    # }}}
# }}}
# Variables definitions {{{
    # set vim as default editor
    export VISUAL=vim
    export EDITOR=$VISUAL

    # User configuration
    export PATH="/usr/local/bin:/usr/bin:/bin:/usr/local/games:/usr/games"
    export MANPATH="/usr/local/man:$MANPATH"

    # yarn
    export PATH="$HOME/.yarn/bin:$HOME/.config/yarn/global/node_modules/.bin:$PATH"

    # Tmux plugin need it to start Tmux at connexion
    export ZSH_TMUX_AUTOSTART=true

    # Path to oh-my-zsh installation.
    export ZSH=~/.oh-my-zsh
# }}}
# Aliases {{{
    if [ -f ~/.bash_aliases ]; then
        . ~/.bash_aliases
    fi
# }}}
# Completion {{{
    # enable completion
    autoload -Uz compinit && compinit
    zmodload zsh/complist

    # added by zsh auto install
    zstyle :compinstall filename '/home/afabre/.zshrc'

    # allow autocomplet on zshrc aliases and selection of suggestions
    zstyle ':completion:*' menu select
    setopt completealiases

    # pick item but stay in the menu
    bindkey -M menuselect "+" accept-and-menu-complete

    # command auto-correction.
    ENABLE_CORRECTION="true"

    # display red dots whilst waiting for completion.
    COMPLETION_WAITING_DOTS="true"
# }}}
# History {{{
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
# }}}
# Key binding {{{
    bindkey -v

    # Arrows for reverse search
    bindkey '^[[A' up-line-or-search
    bindkey '^[[B' down-line-or-search
# }}}
# Sourcing oh my zsh {{{
    source $ZSH/oh-my-zsh.sh
# }}}
# Fancy prompt {{{
    autoload -U promptinit
    autoload -U colors && colors
    promptinit

# Don't try to indent these lines, it messes up the prompt
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
    # if [ -f ~/.dircolors ]
    # then
        # eval `dircolors ~/.dircolors`
    # fi
# }}}
# FZF configuration {{{
    # FZF can be installed from a `:PlugInstall` in vim
    [ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
    # Set FZF to use ag if it is installed
    command -v ag >/dev/null 2>&1 && export FZF_DEFAULT_COMMAND='ag --nocolor -f --hidden --ignore .git -g ""'
# }}}
