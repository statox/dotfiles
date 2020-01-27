" ~/.vim/autoload
" vim:fdm=marker

function! common_web_settings#createMappings()
    " Helper code snippets {{{
        inoremap <buffer> debug debugger; // AFA
        inoremap <buffer> clog console.log();<Left><Left>
        inoremap <buffer> clo' console.log('');<Left><Left><Left>
        inoremap <buffer> c=== console.log('=========================================================');
        inoremap <buffer> c### console.log('#########################################################');
        inoremap <buffer> c--- console.log('---------------------------------------------------------');
        inoremap <buffer> c*** console.log('*********************************************************');
        inoremap <buffer> c^^^ console.log('^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^');
        inoremap <buffer> cvvv console.log('vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv');
        inoremap <buffer> qlog console.log("", );
        inoremap <buffer> stdout process.stdout.write( + '\n');<Left><Left><Left><Left><Left><Left><Left><Left><Left>
        inoremap <buffer> isundef typeof === 'undefined'<Esc>2F<space>a
        inoremap <buffer> isdef typeof !== 'undefined'<Esc>2F<space>a
        inoremap <buffer> isnumber typeof === 'number'<Esc>2F<space>a

        inoremap <buffer> callmodule if (require.main === module) {appelDeTest();}
    " }}}
    " Linter {{{
        nnoremap <buffer> <F5> :silent make! % \| silent redraw!<CR>
        nnoremap <buffer> <Leader>. :LspCodeAction<CR>
    " }}}
endfunction
