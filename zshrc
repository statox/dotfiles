#~/.zshrc
# vim:fdm=marker

# Hacky hack
# `python` is not available but `python3` is.
# The `python` command is needed by git-prompt plugin
# TODO find a way to fix that properly
alias python='python3'
# tmux plugin configuration {{{
    export ZSH_TMUX_AUTOQUIT='false'
    export ZSH_TMUX_AUTOCONNECT='false'
    # Tmux plugin need it to start Tmux at connexion
    export ZSH_TMUX_AUTOSTART=true
# }}}
# Plugins {{{
    # IMPORTANT: zsh-syntax-highlighting MUST be placed in last position
    plugins=(bgnotify colored-man-pages cp docker docker-compose extract git git-prompt npm tmux z zsh-syntax-highlighting)

    # zsh-syntax-highlighting configuration {{{
        # Remember to git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ~/.oh-my-zsh/custom/plugins
        # to get the plugin working

        # Add additional highlighters
        ZSH_HIGHLIGHT_HIGHLIGHTERS=(main brackets pattern cursor)

        # Configure highlighters colors
        typeset -A ZSH_HIGHLIGHT_STYLES
        ZSH_HIGHLIGHT_STYLES[command]='fg=71'   # Green
        ZSH_HIGHLIGHT_STYLES[path]='fg=yellow'
        ZSH_HIGHLIGHT_STYLES[unknown-token]='fg=124,bold' # Red
    # }}}
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
    export FZF_DEFAULT_OPTS='--height 40% --tmux bottom,40% --border none --no-separator'
    # Setup the keybinding for ctrl-r, ctrl-t, etc
    source <(fzf --zsh)
# }}}
# NVM configuration {{{
export NVM_DIR="$HOME/.config/nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
# }}}
# Necessary to make kitty work
export TERM=screen-256color

# Completion for local command isp
# compdef -a _custom-iam-switch-profile custom-iam-switch-profile

# Dashlane containerized tools
export DOCKER_TOOLS_ENABLED=false
export DOCKER_TOOLS_PROJECTS='/home/adrien/projects'
export WORKSPACES='/home/adrien/projects'
export DOCKER_TOOLS_RUNNER='podman'

export MOCHA_COLORS=true
