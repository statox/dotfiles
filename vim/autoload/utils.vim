" ~/.vim/autoload/utils.vim
"
" A collection of miscellanous autoloading functions

function! utils#IsProjectDirectory() abort
    return (
                \ isdirectory('.git')
                \ || filereadable('pom.xml')
                \ || filereadable('.eslintrc')
                \ )
endfunction
