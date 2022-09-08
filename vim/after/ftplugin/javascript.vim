" ~/.vim/after/ftplugin
" vim:fdm=marker

" Guard {{{
    if exists("b:did_ftplugin_custom")
        finish
    endif
    let b:did_ftplugin_custom = 1
" }}}
" JS snippets {{{
    call common_web_settings#createMappings()
" }}}
" Configs {{{
    setlocal colorcolumn=100,120
" }}}
" Grep {{{
    set grepprg=grep\ -nr\ $*\ /dev/null
" }}}
