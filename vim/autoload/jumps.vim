" Repeat <C-o> or <C-i> jump commands until the current buffer changes
" or no other jumps are available
function jumps#fileCO(up)
    let current_buffer = bufnr()

    " Get the jump list and parse the position of the first jump in the list
    " if the number is zero then we reached the top
    redir => jumps_output
    silent jumps
    redir END
    let lastjump = split(jumps_output, '\n')[1]
    let lastjumppos = str2nr(matchstr(lastjump, '\d\+'))

    " Execute the jump command until the buffer changes or there are no more jumps
    while bufnr() == current_buffer && lastjumppos > 0
        if a:up == v:true
            execute "normal! \<c-o>"
        else 
            " \<CR> is an ugly hack to do nothing but let the normal command
            " see that it has an argument
            execute "normal! \<CR>\<c-i>"
        endif
        let lastjumppos = lastjumppos - 1
    endwhile
endfunction
