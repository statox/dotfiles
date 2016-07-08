"~/.vimrc
" vim:fdm=marker

" General configuration {{{
    set nocompatible    " Required, fix lot of stuff
    filetype on         " Detect the type of a file based on its name
    syntax on           " Enable syntax highlighting

    let mapleader="\<Space>"    " remap mapleader to space

    " Allow to change buffer even if the current one is not written
    set hidden

    " Better command-line completion
    set wildmenu
    set wildmode=longest,list,full

    " Do not show partial commands in the last line of the screen
    set noshowcmd

    " Allow backspacing over autoindent, line breaks and start of insert action
    set backspace=indent,eol,start

    " Raise dialog instead of failing a command because of unsaved changes
    set confirm

    " Use visual bell instead of beeping when doing something wrong
    set visualbell

    " Enable use of the mouse for all modes
    set mouse=a

    " Set the command window height to 2 lines, to avoid many cases of having to
    " "press <Enter> to continue"
    set cmdheight=2

    " Display line numbers on the left
    set number
    set relativenumber

    " Quickly time out on keycodes, but never time out on mappings
    set notimeout ttimeout ttimeoutlen=200

    " set some mapping to work with an azerty keyboard
    set langmap+=à@,ù%

    " change the current directory when openning a new file
    autocmd BufEnter * silent! lcd %:p:h

    " automatically reload file when its modified outside vim 
    set autoread

    " Allows vim to record more lines in history
    set history=500

    " Swap and backup files are pretty annoying: get rid of them
    set noswapfile nobackup

    " make autocomplete case sensitive even if 'ignorecase' is on
    set infercase
    set completeopt=longest,menuone,preview

    " Add subdirectories to path
    set path +=**

    " Show unseeing characters
    set list
    set listchars=eol:$,tab:>-,trail:.
"}}}
" Plugins {{{
    " Manage plugins with vim-plug (https://github.com/junegunn/vim-plug)
    " to install execute:
    " curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
    call plug#begin('~/.vim/plugged')
    " Use a local file for plugins which shouldn't be synched in github {{{
        if has('win32')
            let $MYLOCALPLUG = $HOME . "/_local.plug.vim"
        else
            let $MYLOCALPLUG = $HOME . "/.local.plug.vim"
        endif
        if filereadable($MYLOCALPLUG)
            source $MYLOCALPLUG
        endif
    "}}}
    " scrooloose/nerdcommenter: Vim plugin for intensely orgasmic commenting{{{
        Plug 'scrooloose/nerdcommenter'
    "}}}
    " godlygeek/tabular: Vim script for text filtering and alignment{{{
        Plug 'godlygeek/tabular'
    "}}}
    " ervandew/supertab: completion with <Tab>{{{
        Plug 'ervandew/supertab'
    "}}}
    " tpope/vim-surround: Surround text with matching caracters{{{
        Plug 'tpope/vim-surround'
    "}}}
    " junegunn/vim-oblique: Improved search for Vim.{{{
        Plug 'junegunn/vim-oblique' | Plug 'junegunn/vim-pseudocl'

        " Clear autocommand
        autocmd! User Oblique
        autocmd! User ObliqueStar
        autocmd! User ObliqueRepeat

        " Put the cursor in the middle of the screen at each match
        autocmd User Oblique       normal! zz
        autocmd User ObliqueStar   normal! zz
        autocmd User ObliqueRepeat normal! zz
    "}}}
    " nanotech/jellybeans.vim: Cool colorscheme{{{
        Plug 'nanotech/jellybeans.vim'
    "}}}
    " Snippets pluggins: Group dependencies, vim-snippets depends on ultisnips{{{
        if has('python')
            Plug 'SirVer/ultisnips' | Plug 'honza/vim-snippets'    

            " Trigger snippets two *
            inoremap ** <C-R>=UltiSnips#ExpandSnippetOrJump()<CR>
            " Switch between the place holder with arrow keys
            let g:UltiSnipsJumpForwardTrigger="<Right>"
            let g:UltiSnipsJumpBackwardTrigger="<Left>"
            " Make :UltiSnipsEdit split window vertically
            let g:UltiSnipsEditSplit="vertical"

            " Add directory containing my custom plugins
            set runtimepath +=~/.vim/my-snippets
        endif
    "}}}
    " statox/vim-compare-lines: Easily compare two lines of a buffer {{{
        Plug 'statox/vim-compare-lines'
    " }}}
    " justinmk/vim-dirvish: Directory viewer for vim {{{
        Plug 'justinmk/vim-dirvish'
    " }}}
    " nobe4/vimcorrect: Enhance the correction mechanism {{{
        Plug 'nobe4/vimcorrect'
    " }}}
    call plug#end()

    " matchit: expand matching text objects{{{
        runtime macros/matchit.vim
    "}}}
    "" netrw: The builtin file explorer{{{

        ""use tree view
        "let g:netrw_liststyle=3 " Bad idea thats actually pretty bugged
    ""}}}
"}}}
" Mappings {{{
    " <C-L> turn off search highlighting until the next search {{{
        nnoremap <C-L> :nohl<CR><C-L>
    "}}}
    " Fast save and quit {{{
        nnoremap <Leader>x     :x<CR>
        nnoremap <Leader>q     :q<CR>
        nnoremap <Leader><S-Q> :qa!<CR>
    "}}}
    " Go to 80column {{{
        nnoremap <Leader><tab> 80\|
    "}}}
    " In visual mode use A to select all of the file {{{
        vnoremap aa <esc>gg0vG$
    "}}}
    " Easier clipboard access {{{
        if has('clipboard')
            if has('win32') || has('win64')
                vnoremap <Leader>y "*y

                vnoremap <Leader>p "*p
                nnoremap <Leader>p "*p

                vnoremap <Leader><S-p> "*P
                nnoremap <Leader><S-p> "*P
            else
                vnoremap <Leader>y "+y

                vnoremap <Leader>p "+p
                nnoremap <Leader>p "+p

                vnoremap <Leader><S-p> "+P
                nnoremap <Leader><S-p> "+P
            endif
        endif
    "}}}
    " Quickly escape insert mode with jj {{{
        inoremap jj <Esc>
        inoremap jk <Esc>:w<CR>
        " Let's try it in normal mode too
        nnoremap  <Leader>jk <Esc>:w<cr>:echo "saving"<CR>
    "}}}
    " Quickly insert an empty new line without entering insert mode {{{
        nnoremap <Leader>o o<Esc>0"_D
        nnoremap <Leader>O O<Esc>0"_D
    "}}}
    " insert newline in normal mode {{{
        nnoremap <Leader><CR> i<CR><esc>
    "}}}
    " Use T in visual mode to start Tabular function {{{
        vnoremap T :Tabular / 
    "}}}
    " Use gp to select last pasted text {{{
        nnoremap gp '[v']
    "}}}
    " Record macros with Q instead of q {{{
        nnoremap Q q
        nnoremap q <Nop>
    "}}}
    " Delete the current word in insert mode with <C-backspace> {{{
        inoremap  <C-w>
    " }}}
    " Use s instead of <C-w> to handle windows {{{
        nnoremap s <C-w>
    " }}}
    " Show the current file name with <leader>f {{{
        nnoremap <Leader>f :echo expand('%:p')<CR>
    " }}}
"}}}
" Manage tabs {{{
    " move to new/previous tabs
    noremap <Leader><Leader>l  :tabn<CR>
    noremap <Leader><Leader>h  :tabp<CR>
    " open/close tab
    noremap <Leader><Leader>t  :tabnew<CR>
    noremap <Leader>tc         :tabclose<CR>
    " move current tab to left/right
    noremap <Leader><Leader><Left>  :execute 'silent! tabmove -1'<CR>
    noremap <Leader><Leader><Right> :execute 'silent! tabmove +1'<CR>
"}}}
" Manage buffers {{{
    " show buffer list and allow to type the buffer name to use with <Leader>bb
    noremap <Leader>bb :ls<CR>:b
    " change buffer with <Leader>bh and <Leader>bl
    noremap <Leader>l :bn<CR>
    noremap <Leader>h :bN<CR>
    " close a buffer with <Leader>bc
    noremap <Leader>bc :bd<CR>
    " open buffer with <Leader><Leader>b
    nnoremap <Leader><Leader>b :enew<CR>
"}}}
" Color configuration {{{
    try
        set background=dark
        colorscheme jellybeans
    catch
        echo "Colorscheme not found"
    endtry
"}}}
" Color 81st column on too long lines(Put this AFTER colorscheme definition) {{{
    highlight ColorColumn ctermbg=black ctermfg=red guibg=black guifg=red
    call matchadd('ColorColumn', '\%#=1\%81v', 100)
    "call matchadd('ColorColumn', '\%81v', 100)
"}}}
" status line configuration {{{
    " Display the cursor position in the status line
    set noruler

    " Always display the status line, even if only one window is displayed
    set laststatus=0
"}}}
" Text, tab and indent related configuration {{{
    " Use spaces instead of tabs
    set expandtab
    " Be smart when using tabs ;)
    set smarttab

    " 1 tab == 4 spaces
    set shiftwidth=4
    set tabstop=4

    " Linebreak on 500 characters
    set lbr
    set tw=500
    set autoindent   " Auto indent
    set smartindent  " Smart indent
    set wrap         " Wrap lines
"}}}
" Set up smarter search behaviour {{{
    set incsearch   " Lookahead as search pattern is specified
    set ignorecase  " Ignore case in all searches...
    set smartcase   " unless uppercase letters used
    set hlsearch    " Highlight all matches
                    " use <C-L> to temporarily turn off highlighting

    highlight clear Search
"}}}
"Configuration specific to gvim {{{
    " Maximize window when starting gVim (works on MS windows only)
    autocmd GUIEnter * simalt ~n

    " Remove useless graphical stuff
    set guioptions-=m  "menu bar
    set guioptions-=T  "toolbar
    set guioptions-=r  "right-hand scroll bar
    set guioptions-=L  "left-hand scroll bar
"}}}
" Rename TMUX tab vim name of edited file {{{
    autocmd BufReadPost,FileReadPost,BufNewFile,BufEnter * call system("tmux rename-window '" . expand("%:t") . "'")
" }}}
" Custom functions and commands {{{
    " Get a link to the online page of an help tag {{{
        function! GetOnlineDoc(string)

            " Go to specified help tag locally
            execute "h " . a:string

            " Get the help filename without the ".txt" extension
            let filename = expand("%:t:r")

            " Replace some characters to get a correct url
            let string = substitute(a:string, "'", "%27", "g")

            " Create the link
            let link = "http://vimdoc.sourceforge.net/htmldoc/" . filename . ".html#" . string

            let link = "[`:h " . a:string . "`](" . link . ")"

            " Put it in the clipboard register
            if has('win32')
                let @* = link
            else
                let @+ = link
            endif

            " Optional, close the opened help file
            "execute "bd"
        endfunction

        command! -nargs=1 -complete=help GOD call GetOnlineDoc(<f-args>)
    "}}}
    " Toggle number on windows which are not the current one {{{
        " This function allow 2 behaviors:
        " - current window has number and relativenumber and other window has nothing
        " - current window has number and relativenumber and other window has number
        " The command ToggleNumbersInOtherWindows allows to toggle these behaviors
        function! ToggleNumbersAutoGroup()
            let l:currentWindow=winnr()
            if !exists('#NumbersOn#WinEnter')
                augroup NumbersOn
                    autocmd!
                    autocmd WinEnter * if &ft!="help" | setlocal number | endif
                    autocmd WinEnter * if &ft!="help" | setlocal relativenumber | endif
                    autocmd WinLeave * setlocal nonumber
                    autocmd WinLeave * setlocal norelativenumber
                augroup END
                augroup NumbersOff
                    autocmd!
                augroup END
                windo setlocal nonumber norelativenumber
                exe l:currentWindow . "wincmd w"
                setlocal number relativenumber
            else
                augroup NumbersOff
                    autocmd!
                    autocmd WinEnter * setlocal number
                    autocmd WinEnter * setlocal relativenumber
                    autocmd WinLeave * setlocal norelativenumber
                augroup END
                augroup NumbersOn
                    autocmd!
                augroup END
                windo setlocal number norelativenumber
                exe l:currentWindow . "wincmd w"
                setlocal relativenumber
            endif
        endfunction
        call ToggleNumbersAutoGroup()

        command! ToggleNumbersInOtherWindows call ToggleNumbersAutoGroup()
    "}}}
    " make h and l skip indentation white spaces {{{
        function! MyLMotion()
            let cursorPosition=getpos(".")
            normal ^
            let firstChar=getpos(".")

            if cursorPosition[2] < firstChar[2]
                normal ^
            else
                call setpos('.', cursorPosition)
                normal! l
            endif
        endfunction

        function! MyHMotion()
            let cursorPosition=getpos(".")
            normal ^
            let firstChar=getpos(".")

            if cursorPosition[2] <= firstChar[2]
                normal 0
            else
                call setpos('.', cursorPosition)
                normal! h
            endif
        endfunction

        nnoremap <silent> h :call MyHMotion()<CR>
        nnoremap <silent> l :call MyLMotion()<CR>
    "}}}
    " Get a random number using system function {{{
    " http://vi.stackexchange.com/a/819/1821
        function! GetRandomInteger()
            if has('win32')
                return system("echo %RANDOM%")
            else
                return system("echo $RANDOM")
            endif
        endfunction
    " }}}
    " Open help vertically with H {{{
        command! -complete=help -nargs=1 H call VerticalHelp(<f-args>)
        function! VerticalHelp(topic)
            execute "vertical botright help " . a:topic
            execute "vertical resize 78"
        endfunction
    "}}}
    " :W save file with sudo permissions {{{
        command! W w !sudo tee % > /dev/null
    "}}}
"}}}
" Filetype specific configurations {{{
    " text {{{
            " set tw=80 and wrap text
            "autocmd! FileType text setlocal tw=80 | normal gggqG
    " }}}
    " vim {{{
            " Use <F3> to source
            autocmd FileType vim  nnoremap <buffer> <F3> :so %<CR>
    " }}}
" }}}
" Source a local vimrc {{{
    if has('win32')
        let $MYLOCALVIMRC = $HOME . "/_local.vim"
    else
        let $MYLOCALVIMRC = $HOME . "/.local.vim"
    endif

    if filereadable($MYLOCALVIMRC)
        source $MYLOCALVIMRC
    endif
" }}} 
