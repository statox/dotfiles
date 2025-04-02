#~/.zshrc
# vim:fdm=marker

# Thinkpad PF514G4Z: Setup keyboard layout to qwerty + remap caps to escape{{{
    setxkbmap -model pc105 -layout us -option caps:escape
# }}}
# Python alias {{{
    # Hacky hack: By default on Ubuntu `python` is not available but `python3` is.
    # The `python` command is needed by git-prompt plugin
    # TODO find a way to fix that properly
    # Note: This alias is here since September 2022. It's probably not worth fixing in the end
    alias python='python3'
# }}}
# Plugins {{{
    plugins=(bgnotify colored-man-pages docker docker-compose extract git-prompt npm nvm z)
    # Don't let oh-my-zsh plugins install their aliases
    zstyle ':omz:plugins:*' aliases no
    zstyle ':omz:plugins:z' aliases yes
# }}}
# NVM {{{
# We use the oh-my-zsh nvm plugin to load nvm so this configuration must happen before sourcing oh-my-zsh

# Using lazy loading to considerably reduce zsh startup time
zstyle ':omz:plugins:nvm' lazy yes
# list of commands which trigger loading nvm. Nvim is here because some LSP servers need node in the path
zstyle ':omz:plugins:nvm' lazy-cmd git nvim terraform uv
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

    # local bin
    export PATH="$HOME/.bin:$PATH"
    export PATH="$HOME/.local/bin:$PATH"

    # yarn
    export PATH="$HOME/.yarn/bin:$HOME/.config/yarn/global/node_modules/.bin:$PATH"

    # snaps
    export PATH="$PATH:/snap/bin/"

    # Path to oh-my-zsh installation.
    export ZSH=~/.oh-my-zsh
# }}}
# Completion {{{
    # enable completion
    autoload -Uz compinit && compinit
    zmodload zsh/complist

    # added by zsh auto install
    zstyle :compinstall filename "$HOME/.zshrc"

    # allow autocomplet on zshrc aliases and selection of suggestions
    zstyle ':completion:*' menu select
    # setopt completealiases

    # pick item but stay in the menu
    bindkey -M menuselect "+" accept-and-menu-complete

    # Avoid polluting home with .zcompdump* files
    # https://stackoverflow.com/a/71271754/4194289
    export ZSH_COMPDUMP=$ZSH/cache/.zcompdump-$HOST

    # command auto-correction.
    ENABLE_CORRECTION="true"

    # display red dots whilst waiting for completion.
    COMPLETION_WAITING_DOTS="true"

    # That's weird but it allows aliases like 'gco' to get proper completion
    setopt no_complete_aliases

    # File generated with npm completion > ~/.npm_completion.sh
    [ -f ~/.npm_completion.sh ] && source ~/.npm_completion.sh
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
    HIST_STAMPS="%d/%m/%y %T"

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

    bindkey '^a' beginning-of-line
    bindkey '^e' end-of-line
# }}}
# Sourcing oh my zsh {{{
    source $ZSH/oh-my-zsh.sh
# }}}
# Aliases {{{
    if [ -f ~/.bash_aliases ]; then
        . ~/.bash_aliases
    fi
# }}}
# Fancy prompt {{{
    autoload -U promptinit
    autoload -U colors && colors
    promptinit

# One can use the shell command spectrum_ls to know which color to
# use in the variable $FG

# Customize git-prompt colors
export ZSH_THEME_GIT_PROMPT_BRANCH="%{$fg_bold[yellow]%}"

# Don't try to indent these lines, it messes up the prompt
PROMPT="\
%{$FG[025]%}%n\
%{$reset_color%}@\
%{$FG[100]%}%m\
%{$reset_color%} "

# the plugin git-prompt already set the first part of RPROMPT
RPROMPT=$RPROMPT"\
%{$FG[202]%}%3~\
%{$reset_color%}"
# }}}
# FZF configuration {{{
    # This config works with fzf 0.60+, on Ubuntu that requires installing the binary instead of using the apt repo version
    # Set FZF to use ag if it is installed
    command -v ag >/dev/null 2>&1 && export FZF_DEFAULT_COMMAND='ag --nocolor -f --hidden --ignore .git -g ""'
    export FZF_DEFAULT_OPTS='--height 90% --border none --no-separator'
    # Setup the keybinding for ctrl-r, ctrl-t, etc
    source <(fzf --zsh)
# }}}

export MOCHA_COLORS=true
