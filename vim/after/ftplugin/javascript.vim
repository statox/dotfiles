" javascript ftplugin

" Setting elint to check the file
setlocal errorformat=%f:\ line\ %l\\,\ col\ %c\\,\ %m,%-G%.%#
setlocal makeprg=eslint\ --format\ compact

augroup JS
    autocmd!
    autocmd BufWritePost <buffer> silent make! <afile> | silent redraw!
augroup END

" Set fold settings for JS
augroup JSFold
    autocmd!
    autocmd BufEnter <buffer> set foldmethod=indent foldlevel=1 foldlevelstart=1
    autocmd BufLeave <buffer> set foldmethod& foldlevel& foldlevelstart&
augroup END

" JS snippets
inoremap <buffer> debug debugger; //AFA
inoremap <buffer> log console.log();<C-O><Left>
