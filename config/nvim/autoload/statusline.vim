" ~/.vim/autoload/statusline.vim
" Functions used in the customization of the status line

function! statusline#StatusDiagnostic() abort
    let info = get(b:, 'coc_diagnostic_info', {})
    if empty(info) | return '' | endif

    let msgs = []
    if get(info, 'error', 0)
        call add(msgs, 'E' . info['error'])
    endif

    if get(info, 'warning', 0)
        call add(msgs, 'W' . info['warning'])
    endif

    return '[' . join(msgs, ' ') . ' ' . get(g:, 'coc_status', '') . ']'
endfunction

" Return the nearest function using coc
function! statusline#CurrentFunction()
    if (exists('b:term_title'))
        return ''
    endif

    let currentFunctionSymbol = get(b:, 'coc_current_function', 'X')
    return '[' . currentFunctionSymbol . ']'
endfunction

" Return the current git branch as a string
" function! SLCurrentGitBranch()
function! statusline#CurrentGitBranch()
    "let gitoutput = systemlist('git branch 2> /dev/null | sed -e "/^[^*]/d" -e "s/* \(.*\)/(\1)/" -e "s/[()]//g";')

    "if len(gitoutput) > 0
    "    let gitoutput = strcharpart(gitoutput[0], 0, 25)
    "    return '[' . gitoutput . ']'
    "endif
    "return ''

    return exists('*FugitiveHead') ? '[' . FugitiveHead() . ']' : ''
endfunc

" Return the git status of a file
function! statusline#CurrentFileGitStatus()
    let gitStatus = systemlist('git status --porcelain ' . shellescape(expand('%')) . ' 2> /dev/null | sed -E "s/\s*(\w+).*/\1/"')

    if len(gitStatus) > 0
        return '[' . gitStatus[0] . ']'
    endif
    return ''
endfunction

" Return the time of last modification (HH:MM) and the time in
" since last modification ([xh:][xm:][xs])
function! statusline#TimeSinceLastUpdate()
    if (expand('%') == '')
        return ''
    endif

    if (exists('b:term_title'))
        return ''
    endif

    let secondsSinceLastUpdate = localtime() - getftime(expand('%'))
    let statusLineTime = ''

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

        let statusLineTime = strftime('%R',getftime(expand('%'))) . ' - '
    endif

    return '[' . statusLineTime . timeSinceLastUpdate . ']'
endfunction

function! statusline#SetStatusLine()
    set statusline=

    " Flags modified buffer and help file
    if (exists('b:term_title'))
        set statusline+=%#Error#
        set statusline+=%m%h
        set statusline+=%*

        " Quick/Location List
        set statusline+=%#DiffAdd#
        set statusline+=%q
        set statusline+=%*

        " current row/total rows current column
        set statusline+=[%l/%L-%c]
    endif

    " Short name of the file
    set statusline+=[\%t\]
    " Nearest function if it exists
    set statusline+=%{statusline#CurrentFunction()}

    " Separator right-aligned left-aligned
    set statusline+=%=

    " Coc.nvim diagnostics
    set statusline+=%{statusline#StatusDiagnostic()}

    " Last modification time - time since last modification
    set statusline+=%{statusline#TimeSinceLastUpdate()}
endfunction
