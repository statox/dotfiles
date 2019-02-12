" Expose a simple API to start and stop the search highlighting
function search#StartStatuslineHighlighting()
    if (has('timers'))
        call search#HighlightSearch(1, 1, 0)
    endif
endfunction

function search#StopStatuslineHighlighting()
    if (has('timers'))
        call search#HighlightSearch(0, 0, 0)
    endif
endfunction

" The function actually changing the statusline HL if needed
function! search#HighlightSearch(firstCall, searching, timer)
    " When it is the first call to the function we save the current status of
    " the StatusLine HL group so that we can restore it when we are done searching
    if (a:firstCall)
        let s:originalStatusLineHLGroup = execute("hi StatusLine")
    endif

    " If we are searching something and the current command line is ? or /
    " then make the highlighting and call the function again after a delay
    if (index(['?', '/'], getcmdtype()) >= 0 && a:searching)
        " Checking the results of the search and updating the StatusLine HL
        " TODO make that more generic: There should be a better way than using search()
        let searchString = escape(getcmdline(), ' \')
        try
            let newBG = search(searchString) != 0 ? "green" : "red"
        catch /E35/
            let newBG = "green"
        endtry

        " TODO make that configurable so that it also works with GUI
        " Maybe we could let the user define a dictionnary with the items they want to change
        execute("hi StatusLine ctermbg=" . newBG)

        " Start a timer to execute the function again put the firstCall argument to 0
        " but the searching argument to 1
        let delay = get(g:, 'statuslineHL_delay', 300)
        let s:highlightTimer = timer_start(delay, function('search#HighlightSearch', [0, 1]))
    else
        " If we are not in the command line ? or / or we got the searching argument to false
        " then we restore the hightlighting and stop calling the function

        if exists('s:originalStatusLineHLGroup')
            let originalBG = matchstr(s:originalStatusLineHLGroup, 'ctermbg=\zs[^ ]\+')
            execute("hi StatusLine ctermbg=" . originalBG)
        endif

        if exists("s:highlightTimer")
            call timer_stop(s:highlightTimer)
            unlet s:highlightTimer
        endif
    endif
endfunction
