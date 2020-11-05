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
" Mappings {{{
    nmap <buffer><silent> <F1>  :<C-u>CocList diagnostics<cr>

    " Use `[c` and `]c` for navigate diagnostics
    nmap <buffer><silent> [c <Plug>(coc-diagnostic-prev)
    nmap <buffer><silent> ]c <Plug>(coc-diagnostic-next)

    " Remap keys for gotos
    nmap <buffer><silent> gd <Plug>(coc-definition)
    nmap <buffer><silent> gy <Plug>(coc-type-definition)
    nmap <buffer><silent> gi <Plug>(coc-implementation)
    nmap <buffer><silent> gr <Plug>(coc-references)

    " Documentation
    nmap <buffer><silent> K :call CocAction('doHover')<CR>

    " Remap for do codeAction of selected region, ex: `<leader>aap` for current paragraph
    vmap <leader>a  <Plug>(coc-codeaction-selected)
    nmap <leader>a  <Plug>(coc-codeaction-selected)
" }}}


