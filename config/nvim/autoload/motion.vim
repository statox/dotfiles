" make h and l skip indentation white spaces
function! motion#SkipOrL()
    let cursorPosition=getpos(".")
    normal ^
    let firstChar=getpos(".")

    if cursorPosition[2] < firstChar[2]
        normal ^
    else
        call setpos('.', cursorPosition)
        normal! l
    endif
endfunction

function! motion#SkipOrH()
    let cursorPosition=getpos(".")
    normal ^
    let firstChar=getpos(".")

    if cursorPosition[2] <= firstChar[2]
        normal 0
    else
        call setpos('.', cursorPosition)
        normal! h
    endif
endfunction
