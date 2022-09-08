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
