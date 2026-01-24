# ~/.bash_aliases
# vim:ft=bash fdm=marker

# Local aliases {{{
# Aliases used only in this machine (not synched with git)
if [ -f ~/.bash_aliases_local ]; then
    . ~/.bash_aliases_local
fi
# }}}
# ls {{{
alias la='ls -ACF'
alias ldot='ls -d .*'
alias ll='ls -AlFh'
# }}}
# git {{{
alias g='git'
alias gs='git status -s'
alias gss='git status'
alias gd='improvedGitDiff'
alias gfu='improvedGitFixup'
alias gdc='git diff --cached'
alias ga='git add'
alias gp='git push'
alias gc='git commit'
alias gl='git pull --rebase'
alias glg='git log'
alias glgs='git log --show-signature'
alias glgp='git log -p'
alias glgn='git log --name-only'
alias gco='git checkout'
alias glgme='git log --author "$(git config user.name)"'
alias glgpme='git log -p --author "$(git config user.name)"'
alias gcoi='git checkout $(git branch | fzf)'
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

improvedGitDiff() {
    # If any argument is passed behave like git diff
    if [ "$#" -gt 0 ]; then
        git diff "$@"
        return 0
    fi

    # Open fzf with currently modified files as choices
    # The preview window shows the diff for the file
    # $(git rev-parse --show-toplevel) returns the root of the git directory
    # and {-1} is the file path from the root directory
    # We need that otherwise then calling the function from a subdirectory in the project won't work
    preview="git diff $@ --color=always -- $(git rev-parse --show-toplevel)/{-1}"
    # bind options: Use
    # ctrl-j/ctrl-k to scroll the preview
    # ctrl-y to yank the current file name in the tmux buffer
    bind_yank='ctrl-y:execute-silent(tmux set-buffer $(echo -n {-1}))+abort'
    bind_scroll='ctrl-j:preview-down,ctrl-k:preview-up'
    local selection=$( git diff "$@" --name-only | fzf -m --tmux center,95% --preview-border none --border none --ansi --reverse --preview "$preview" --bind "$bind_yank" --bind "$bind_scroll" --preview-window top,90%,wrap)
    # Put the selected lines in the next prompt line (only work with ZSH)
    # TODO find a way to move the cursor to the begining of the line (probably with zle)
    [ -n "$selection" ] && [ -n $ZSH_VERSION ] && print -z -- "${selection[@]//$'\n'/ }"
}

improvedGitFixup() {
    # Make it easier to fixup a commit:
    #  $ git add ./whatever
    #  $ improvedGitFixup (or gfu) # choose the commit to update from the fzf list
    #       ^ this creates a new commit with some special commit message that git autosquash knows how to handle
    #  $ git rebase -i --autosquash origin/master # does the autosquash, which squashes the commits into the right commits

    if [ "$#" -gt 1 ]; then
        echo "Usage: [commit]"
        echo "Expected 0 or 1 args, got $#"
        return 1
    fi

    if $(git diff --cached --quiet); then
        echo "No files have been staged. Use 'git add' before running this command."
        return 1
    fi

    COMMIT_TO_FIXUP=$1
    if [ -z $COMMIT_TO_FIXUP ]; then
        preview="git log -p -n1 --color=always {1}"
        bind_scroll='ctrl-j:preview-down,ctrl-k:preview-up'
        COMMIT_TO_FIXUP=$(git log --color  --pretty=format:'%C(red)%h%C(reset) - %s %C(green)(%cr) %C(bold blue)<%an>%C(reset)' --abbrev-commit | fzf --ansi --reverse --preview "$preview" --preview-window top,80%,wrap --bind "$bind_scroll" | cut -d' ' -f1)
    fi

    git commit --fixup $COMMIT_TO_FIXUP

    PREVIOUS_COMMIT=$(git rev-parse --short "$COMMIT_TO_FIXUP^1")
    commandToRun="git rebase -i --autosquash $PREVIOUS_COMMIT"
    echo '\nCreated fixup commit. Run the following command to apply:\n'
    echo "    $commandToRun"
    echo "$commandToRun" | xclip -selection clipboard
    echo "       (Command is available in clipboard)"
}
# }}}
# node {{{
alias ni='node -i'
alias npmr='npm run'
alias pnpmr='pnpm run'
alias noded='node --inspect-brk'
# }}}
# vim {{{
alias v='nvim'
alias vi='vim'
alias n='nvim'
alias vim='nvim'
alias lvim='vim -S ~/Session.vim' # restore vim with a session file
# }}}
# man {{{
# Use fzf to fuzzy find man entries and display man page in preview window
alias man='improvedMan'
improvedMan() {
    # If any argument is passed behave like man
    if [ "$#" -gt 0 ]; then
        'man' "$@"
        return 0
    fi

    # bind options: Use
    # ctrl-j/ctrl-k to scroll the preview
    # ctrl-y to yank the current file name in the tmux buffer
    bind_yank='ctrl-y:execute-silent(tmux set-buffer $(echo -n {-1}))+abort'
    bind_scroll='ctrl-j:preview-down,ctrl-k:preview-up'
    preview="MANWIDTH=80 man {1}"
    man_page=$(man -k . | fzf -m --ansi --reverse --preview "$preview" --bind "$bind_yank" --bind "$bind_scroll" --preview-window right,50%,wrap)
    man_entry=$(cut -d ' ' -f1 <<< "$man_page")

    man "$man_entry"
}
# }}}
# cd {{{
alias ..='cd ../'
alias ...='cd ../../'
alias ....='cd ../../../'
alias .....='cd ../../../../'
alias ......='cd ../../../../../'
alias .......='cd ../../../../../../'
alias ........='cd ../../../../../../../'
alias .........='cd ../../../../../../../../'
alias ..........='cd ../../../../../../../../../'
# }}}
# ping {{{
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
# }}}
# Power management {{{
# shutdown
alias shutnow='sudo shutdown -h now'
# restart
alias restnow='sudo shutdown -r now'
# }}}
# Ag - the silver searcher {{{
alias agw='ag --word-regex'
# }}}
# Terraform {{{
alias tf="terraform"
# }}}
# Date and timestamps {{{
alias ts='date +"%s"'
alias ts2date='timestamp2date'
function timestamp2date {
    echo $(date -d @$1)
}
# }}}
# polybar {{{
if [ -f ~/.config/polybar/launch.sh ]; then
    alias polystart='source ~/.config/polybar/launch.sh &'
fi
# }}}
# z + fzf {{{
# directories navigation with z + fzf
# TODO add check for existance of the commands
alias zf='z $(z | fzf)'
# }}}
# sudo {{{
# https://askubuntu.com/a/22043
# alias sudo='sudo '
# Use sode with the current $PATH (useful when using docker)
alias sudop='sudo env PATH=$PATH'
# }}}
# docker {{{
# Use docker with sudo and $PATH set
alias sdocker='sudo env PATH=$PATH docker'
alias sdocker-compose='sudo env PATH=$PATH docker-compose'
# }}}
# ansible {{{
alias ansible-playbook='ansiblePlaybookDebug'
function ansiblePlaybookDebug {
    export ANSIBLE_STDOUT_CALLBACK=default
    echo -n "$@" | grep -q -- "-v" && export ANSIBLE_STDOUT_CALLBACK=yaml

    'ansible-playbook' "$@"
}
# }}}
# o - Open files or directory in GUI application {{{
# (xdg-open is better than gnome-open because it is desktop agnostic)
function o {
    # If no parameter is passed open current folder
    if [ $# -eq 0 ] || [ -z $@ ]; then
        xdg-open ./
    else
        xdg-open $@ 
    fi
}
# }}}
# Extract for common file formats {{{
# Create the function only on bash system, on zsh I use oh-my-zsh extract plugin
if [[ $SHELL =~ 'bash' ]]; then
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
fi
# }}}
# Loop - looping through a command {{{
loop() {
    echo Starting: "$@"
    while true; do
        eval $(printf "%q " "$@")
        sleep 5;
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
# }}}
