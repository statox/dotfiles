" ~/.vim/after/ftplugin
" vim:fdm=marker

" Guard {{{
    if exists("b:did_ftplugin_custom")
        finish
    endif
    let b:did_ftplugin_custom = 1
" }}}
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
    call common_web_settings#createMappings()
" }}}
" " Make gf works with serviceName.functionName {{{
"     set isfname-=.
" " }}}
" " Find a function typed by the user {{{
"     " Open the result either in the current window or in a new tab
"     nnoremap <buffer> <Leader>ff :FF<CR>
"     nnoremap <buffer> <Leader>FF :FFT<CR>
"
"     command! FF call javascript#FindFunctionInput(0)
"     command! FFT call javascript#FindFunctionInput(1)
" " }}}
" " Find the function under the cursor {{{
"     " Open the result either in the current window or in a new tab
"     nnoremap <buffer> <Leader>fd :FD<CR>
"     nnoremap <buffer> <Leader>FD :FDT<CR>
"
"     command! FD call javascript#FindFunctionUnderCursor(0)
"     command! FDT call javascript#FindFunctionUnderCursor(1)
" " }}}
