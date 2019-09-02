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

    " Remap for format selected region
    xmap <leader>f  <Plug>(coc-format-selected)
    nmap <leader>f  <Plug>(coc-format-selected)

    " Remap for do codeAction of selected region, ex: `<leader>aap` for current paragraph
    xmap <leader>a  <Plug>(coc-codeaction-selected)<CR>
    nmap <leader>a  <Plug>(coc-codeaction-selected)<CR>

    " Rename variable under cursor
    nmap <leader>rn <Plug>(coc-rename)
" }}}
" Autocommands {{{
    " Clean up double quotes and trailing whitespaces when writting files
    " This can be disabled by setting g:ts_clean_on_write to 1
    augroup typescriptCleanUp
        autocmd!
        autocmd FileType typescript if !exists('g:ts_clean_on_write') | let g:ts_clean_on_write = 1 | endif
        " Testing a pattern to prevent changing lines with a mix of " and '
        " TODO Expend the pattern to prevent changing commented lines
        " autocmd BufWritePre *.ts,*.tsx if get(g:, 'ts_clean_on_write', 1) | :g/[^']\+"[^']*$/s/"/'/ge | endif
        " autocmd BufWritePre *.ts,*.tsx if get(g:, 'ts_clean_on_write', 1) | :%s/"/'/ge | endif
        autocmd BufWritePre *.ts,*.tsx if get(g:, 'ts_clean_on_write', 1) | :%s/\s\+$//e | endif
    augroup END
" }}}
" Commands {{{
    command! -buffer ReformatImport :s/\([,{]\) /\1\r    /g | s/ }/\r}
    command! -buffer ReformatParams :s/\([,(]\) /\1\r    /g | s/ )/\r}
" }}}
