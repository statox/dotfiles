" ~/.vim/autoload/diff.vim


function! diff#DiffW()
    let opt = ""

    if &diffopt =~ "icase"
        let opt = opt . "--ignore-case "
    endif

    if &diffopt =~ "iwhite"
        let opt = opt . "--ignore-all-space "
        let opt = opt . "--ignore-blank-lines "
        let opt = opt . "--ignore-space-change "
    endif

    silent execute "!diff -a --binary " . opt . v:fname_in . " " . v:fname_new .  " > " . v:fname_out
endfunction
