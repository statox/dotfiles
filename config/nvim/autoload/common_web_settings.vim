" ~/.vim/autoload
" vim:fdm=marker

function! common_web_settings#createMappings()
    " Helper code snippets {{{
        inoremap <buffer> debug debugger; // AFA
        inoremap <buffer> cerr console.error();<Left><Left>
        inoremap <buffer> clog console.log();<Left><Left>
        inoremap <buffer> c=== console.log('=========================================================');
        inoremap <buffer> c### console.log('#########################################################');
        inoremap <buffer> c--- console.log('---------------------------------------------------------');
        inoremap <buffer> c*** console.log('*********************************************************');
        inoremap <buffer> c^^^ console.log('^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^');
        inoremap <buffer> cvvv console.log('vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv');
    " }}}
endfunction
