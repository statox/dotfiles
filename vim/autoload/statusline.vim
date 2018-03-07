" ~/.vim/autoload/statusline.vim
" Functions used in the customization of the status line

" Set the buffer variable b:gitbranch to the current git branch as a string
function! statusline#CurrentGitBranch()
    let gitoutput = systemlist('git branch 2> /dev/null | sed -e "/^[^*]/d" -e "s/* \(.*\)/(\1)/" -e "s/[()]//g";')

    if len(gitoutput) > 0
        let b:statusLineGitBranch = '[' . gitoutput[0] . ']'
    else
        let b:statusLineGitBranch = ''
    endif
endfunc

" Return the git status of a file
function! statusline#CurrentFileGitStatus()
    let gitStatus = systemlist('git status --porcelain ' . shellescape(expand('%')) . ' 2> /dev/null | sed -E "s/\s*(\w+).*/\1/"')

    if len(gitStatus) > 0
        let b:statusLineGitStatus = '[' . gitStatus[0] . ']'
    else
        let b:statusLineGitStatus = ''
    endif
endfunction

" Return the time of last modification (HH:MM) and the time in
" since last modification ([xh:][xm:][xs])
function! statusline#TimeSinceLastUpdate()
    let secondsSinceLastUpdate = localtime() - getftime(expand('%'))
    let b:statusLineTime = ''

    if (secondsSinceLastUpdate >= 86400)
        " If the modification was more than 24 hours ago only show the number of days
        let timeSinceLastUpdate = '>' . (secondsSinceLastUpdate % 86400) / 3600 . 'j'
    else
        " Otherwise show the time of last modification and the time spent since this moment
        let hours   = (secondsSinceLastUpdate % 86400) / 3600
        let minutes = (secondsSinceLastUpdate % 3600) / 60
        let seconds = (secondsSinceLastUpdate % 60)

        let timeSinceLastUpdate = (hours > 0) ? hours . 'h' : ''
        let timeSinceLastUpdate .= (minutes > 0 || hours > 0) ? minutes . 'm' : ''
        let timeSinceLastUpdate .= seconds . 's'

        let b:statusLineTime = strftime('%R',getftime(expand('%'))) . ' - '
    endif

    let b:statusLineTime = '[' . b:statusLineTime . timeSinceLastUpdate . ']'
endfunction

" Return the expression of the statusline option
function! statusline#StatusLine()
    let statusline=""

    " Flags modified buffer and help file
    let statusline.="%#Error#"
    let statusline.="%m%h"
    let statusline.="%*"

    " current row/total rows current column
    let statusline.="[R%l/%L\ C%c]"

    " Path of the file without the filename
    let statusline.="[%{expand('%:h')}]"

    " Short name of the file :: Buffer number
    let statusline.="[\%t\ ::\ \%n]"

    " Separator right-aligned left-aligned
    let statusline.="%="

    " Git status for current file
    let statusline.="%#DiffAdd#"
    let statusline.="%{b:statusLineGitStatus}"
    let statusline.="%*"

    " Git branch
    let statusline.="%{b:statusLineGitBranch}"

    " Last modification time - time since last modification
    let statusline.="%{b:statusLineTime}"

    return statusline
endfunction
