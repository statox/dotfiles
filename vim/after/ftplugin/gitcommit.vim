" gitcommit.vim ftplugin

" start in insert mode at the beginning of the file
augroup insertModeInGitCommit
    autocmd!
    autocmd BufReadPost if &modifiable | execute "normal! gg0" | startinsert | endif
augroup END

" Limit the lines to 60 chars max
set colorcolumn=50,60
