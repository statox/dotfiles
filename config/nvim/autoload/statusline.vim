" ~/.vim/autoload/statusline.vim
" Functions used in the customization of the status line

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

    " Separator right-aligned left-aligned
    set statusline+=%=

    " Last modification time - time since last modification
    set statusline+=%{statusline#TimeSinceLastUpdate()}
endfunction
