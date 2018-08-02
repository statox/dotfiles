" Toggle the quickfix window
function! quickfix#qf_toggle()
    for i in range(1, winnr('$'))
        let bnum = winbufnr(i)
        if getbufvar(bnum, '&buftype') == 'quickfix'
            cclose
            return
        endif
    endfor

    copen
endfunction

" Toggle the locationlist window
function! quickfix#ll_toggle()
    for i in range(1, winnr('$'))
        let bnum = winbufnr(i)
        if getbufvar(bnum, '&buftype') == 'quickfix'
            lclose
            return
        endif
    endfor

    lopen
endfunction

" Select the entry of the quickfix window the closest from the
" current cursor position
" Don't move the cursor position
function! quickfix#SelectClosestEntry()
    " Save the current cursor position
    let cursorSave = getcurpos()
    let winSave = winsaveview()
    let currentWindow = winnr()
    let currentLine = line('.')
    let currentBuffer = bufnr('%')

    " Define if we use the locationlist or the quickfix
    let qf_isLoc = !empty(getloclist(0))

    " Get the content of the quickfix or location list
    " of the current window
    if (l:qf_isLoc == 1)
        let list = getloclist(currentWindow)
    else
        let list = getqflist(currentWindow)
    endif

    " Dont do anything if the list is empty
    if len(list) == 0
        return
    endif

    " Look for the entry in the current buffer the closest from the cursor
    let index = 1
    let lowestDistance = line('$')
    let lowestDistanceIndex = 0
    for entry in list
        let distance = abs(entry.lnum - currentLine)
        if entry.bufnr == currentBuffer && distance < lowestDistance
            let lowestDistance = distance
            let lowestDistanceIndex = index
        endif
        let index = index + 1
    endfor

    " Get the quickfix window number
    let qfWinNr = -1
    for i in range(1, winnr('$'))
        let bnum = winbufnr(i)
        if getbufvar(bnum, '&buftype') == 'quickfix'
            let qfWinNr = i
        endif
    endfor

    " Change the line in the qf window
    if i != -1
        if (l:qf_isLoc == 1)
            lopen
        else
            copen
        endif
        execute 'norm! ' . lowestDistanceIndex . 'G'
        execute "norm! \<CR>"
    endif

    " Restore the cursor position
    execute currentWindow . 'wincmd w'
    call winrestview(winSave)
    call setpos('.', cursorSave)
endfunction
