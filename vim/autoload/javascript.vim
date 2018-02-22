" ~/.vim/autoload/jacascript.vim

" Find a function defined in the current file
function! javascript#FindFunctionInCurrentFile(inputFunction)
    " First try
    let patternToSearch = "^\\s*\\(var\\|\\$scope\\|this\\.\\)\\.\\?\\s*.*" . a:inputFunction . ".*\\s*=\\s*function"
    let found = search(patternToSearch)

    " If we didn't find it make the search less restrictive
    if (found == 0)
        let patternToSearch = "function\\s\\+.*" . a:inputFunction . ".*(.*)"
        let found = search(patternToSearch)
    endif

    " If we didn't find it make the search even less restrictive
    if (found == 0)
        let patternToSearch = ".*" . a:inputFunction . ".*\\s*=\\s*function"
        let found = search(patternToSearch)
    endif
endfunction

" Go to a function in the current file of in another file
" The first argument is a string of the form "file.function(...)"
" The second is a boolean indicating if we open a new tab or not
function! javascript#FindFunctionInProject(searchedExpression, newTab)
    " Remove the parenthesys and the arguments if they exist
    let def = substitute(a:searchedExpression, '(.*', '', '')

    " Split the expression on a dot hoping to get fichier.function of just function
    let defSplit = split(def, '\.')

    " Parse the argument
    if len(defSplit) == 2
        let fileToSearch = defSplit[0]
        let functionToSearch = defSplit[1]
    else
        let fileToSearch = "this"
        let functionToSearch = defSplit[0]
    endif

    " Dont search for the current file
    if (fileToSearch != "this")
        let findCmd = a:newTab ? "tabfind" : "find"
        execute findCmd . " " . fileToSearch
    endif

    " Then search for the function in the current file
    call javascript#FindFunctionInCurrentFile(functionToSearch)
endfunction

" Find a function typed by the user
function! javascript#FindFunctionInput(newTab)
    " Get the user input
    let inputFunction = input("function: ")

    " An empty string will search for the previously searched
    " function
    if (inputFunction != "" || !exists('g:JSFunctionToSearch'))
        let g:JSFunctionToSearch = inputFunction
    endif

    call javascript#FindFunctionInProject(g:JSFunctionToSearch, a:newTab)
endfunction


" Find the function under the cursor
function! javascript#FindFunctionUnderCursor(newTab)
    " Get the WORD under the cursor
    let inputFunction = expand('<cWORD>')

    call javascript#FindFunctionInProject(inputFunction, a:newTab)
endfunction

