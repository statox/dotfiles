" ~/.vim/autoload
" vim:fdm=marker

function! common_web_settings#createMappings()
    " Helper code snippets {{{
        inoremap <buffer> debug debugger; // AFA
        inoremap <buffer> clog console.log();<Left><Left>
        inoremap <buffer> stdout process.stdout.write( + '\n');<Left><Left><Left><Left><Left><Left><Left><Left><Left>
        inoremap <buffer> isundef typeof === 'undefined'<Esc>2F<space>a
        inoremap <buffer> isdef typeof !== 'undefined'<Esc>2F<space>a
        inoremap <buffer> isnumber typeof === 'number'<Esc>2F<space>a

        inoremap <buffer> callmodule if (require.main === module) {appelDeTest();}
    " }}}
    " Linter {{{
        nnoremap <buffer> <F5> :silent make! % \| silent redraw!<CR>
    " }}}
endfunction
