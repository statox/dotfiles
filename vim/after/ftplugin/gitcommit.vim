" gitcommit.vim ftplugin

" start in insert mode at the beginning of the file
augroup insertModeInGitCommit
    autocmd!
    autocmd BufReadPost if &modifiable | execute "normal! gg0" | startinsert | endif
augroup END
