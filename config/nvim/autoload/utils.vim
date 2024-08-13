" ~/.vim/autoload/utils.vim
"
" A collection of miscellanous autoloading functions
function! utils#ReloadOrEdit(...) abort
    if (a:0 > 1)
        echoerr 'Please provide only one argument'
    endif

    if (a:0 == 0)
        e %
    else
        execute "e " . a:1
    endif
endfunction
