" ~/.vim/after/ftplugin
" vim:fdm=marker

" Setting elint to check the file {{{
    setlocal errorformat=%f:\ line\ %l\\,\ col\ %c\\,\ %m,%-G%.%#
    setlocal makeprg=eslint\ --format\ compact
" }}}
" Augroup javascript_folding {{{
    augroup javascript_folding
        au!
        " Should use if pangloss/vim-javascript is installed
        au FileType javascript setlocal foldmethod=syntax
    augroup END
" }}}
" JS snippets {{{
    inoremap <buffer> debug debugger; //AFA
    inoremap <buffer> log console.log();<Left><Left>
    inoremap <buffer> isundef typeof === "undefined"<Esc>2F<space>a
    inoremap <buffer> isdef typeof !== "undefined"<Esc>2F<space>a
    inoremap <buffer> isnumber typeof === "number"<Esc>2F<space>a
" }}}
" Linter {{{
    nnoremap <buffer> <F5> :silent make! % \| silent redraw!<CR>
" }}}
" Make gf works with serviceName.functionName {{{
    set isfname-=.
" }}}
" Find a function typed by the user {{{
    " Open the result either in the current window or in a new tab
    nnoremap <buffer> <Leader>ff :FF<CR>
    nnoremap <buffer> <Leader>FF :FFT<CR>

    command! FF call javascript#FindFunctionInput(0)
    command! FFT call javascript#FindFunctionInput(1)
" }}} 
" Find the function under the cursor {{{
    " Open the result either in the current window or in a new tab
    nnoremap <buffer> <Leader>fd :FD<CR>
    nnoremap <buffer> <Leader>FD :FDT<CR>

    command! FD call javascript#FindFunctionUnderCursor(0)
    command! FDT call javascript#FindFunctionUnderCursor(1)
" }}}
