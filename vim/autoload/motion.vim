" make h and l skip indentation white spaces
function! motion#MyLMotion()
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

function! motion#MyHMotion()
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
