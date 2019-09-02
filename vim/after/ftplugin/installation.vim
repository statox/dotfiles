" Filetype used only for a local file ~/notes/installation.md

nnoremap <buffer> aaa :echo 'COUCOU'<CR>

function! CreateSummary
    call setreg('a', '')
    g/^#/yank A
endfunction
