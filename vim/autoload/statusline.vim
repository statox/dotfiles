" ~/.vim/autoload/statusline.vim
" Functions used in the customization of the status line

" While we are searching something change the background of the statusline
function! statusline#HighlightSearch(firstCall, timer)
    " When it is the first call to the function we save the current status of
    " the StatusLine HL group so that we can restore it when we are done searching
    if (a:firstCall)
        let s:HLSoriginalStatusLineHLGroup = execute("hi StatusLine")
        let g:HLSfirstCall = 0
    endif

    if (exists("g:HLSsearching") && g:HLSsearching)
        " The variable g:HLSsearching is set to 1, we are in the search command line
        " make the highlighting and call the function again after a delay
        let searchString = escape(getcmdline(), ' \')
        let newBG = search(searchString) != 0 ? "green" : "red"
        execute("hi StatusLine ctermbg=" . newBG)
        let g:HLShighlightTimer = timer_start(300, function('statusline#HighlightSearch', [0]))
    else
        " The variable g:HLSsearching is either not set or set to 0, we stopped searching
        " restore the hightlighting and stop calling the function
        let originalBG = matchstr(s:HLSoriginalStatusLineHLGroup, 'ctermbg=\zs[^ ]\+')
        execute("hi StatusLine ctermbg=" . originalBG)

        if exists("g:HLShighlightTimer")
            call timer_stop(g:HLShighlightTimer)
        endif
    endif
endfunction

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
    if exists("b:statusLineGitStatus")
        let statusline.="%{b:statusLineGitStatus}"
    endif
    let statusline.="%*"

    " Git branch
    if exists("b:statusLineGitBranch")
        let statusline.="%{b:statusLineGitBranch}"
    endif

    " Last modification time - time since last modification
    if exists("b:statusLineTime")
        let statusline.="%{b:statusLineTime}"
    endif

    return statusline
endfunction
