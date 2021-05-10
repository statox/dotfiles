" Mappings {{{
    nmap <buffer><silent> <F1>  :<C-u>CocList diagnostics<cr>

    " Use `[c` and `]c` for navigate diagnostics
    nmap <buffer><silent> [c <Plug>(coc-diagnostic-prev)
    nmap <buffer><silent> ]c <Plug>(coc-diagnostic-next)

    " Remap keys for gotos
    nmap <buffer><silent> gd <Plug>(coc-definition)
    nmap <buffer><silent> gD :call CocAction('jumpDefinition', 'tab drop')<CR>zz
    nmap <buffer><silent> gy <Plug>(coc-type-definition)
    nmap <buffer><silent> gi <Plug>(coc-implementation)
    nmap <buffer><silent> gr <Plug>(coc-references)

    " Use <c-space> to trigger completion
    inoremap <silent><expr> <c-@> coc#refresh()

    " Documentation
    nmap <buffer><silent> K :call CocAction('doHover')<CR>

    " Remap for format selected region
    xmap <leader>f  <Plug>(coc-format-selected)
    nmap <leader>f  <Plug>(coc-format-selected)

    " Remap for do codeAction of selected region, ex: `<leader>aap` for current paragraph
    xmap <leader>a  <Plug>(coc-codeaction-selected)<CR>
    nmap <leader>a  <Plug>(coc-codeaction-selected)<CR>

    " Rename variable under cursor
    nmap <leader>rn <Plug>(coc-rename)
" }}}

