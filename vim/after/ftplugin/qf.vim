"qf.vim

" Restoration of settings {{{
    let s:save_cpo = &cpo
    set cpo&vim
    let b:undo_ftplugin = "setl fo< com< ofu<"
"}}}
" setlocal options {{{
    " Don't use text wrapping in the quickfix window {{{
        setlocal nowrap
    " }}}
    " Use only number et no relative numbers {{{
        setlocal norelativenumber
        setlocal number
    "}}}
    " we don't want quickfix buffers to pop up when doing :bn or :bp {{{
        set nobuflisted
    "}}}
"}}}
" Buffer variables {{{
    " are we in a location list or a quickfix list? {{{
        let b:qf_isLoc = !empty(getloclist(0))
    "}}}
"}}}
" mappings {{{
    " Easily navigate quickfix with ]q and [q {{{
        nnoremap ]q :cnext<CR>zz
        nnoremap [q :cprevious<CR>zz
    "}}}
    " Quick qf window resize {{{
        nnoremap <buffer><silent> - :10wincmd -<CR>
        nnoremap <buffer><silent> + :10wincmd +<CR>
    " }}}
    if (b:qf_isLoc)
        nnoremap <buffer> <F1> :lclose<CR>
    else
        nnoremap <buffer> <F1> :cclose<CR>
    endif
"}}}
" autocommands {{{
    augroup quickfix
        autocmd!
        autocmd QuickFixCmdPost [^l]* cwindow
        autocmd QuickFixCmdPost    l* lwindow
    augroup END

" }}}
let &cpo = s:save_cpo
