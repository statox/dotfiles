"~/.vimrc
" vim:fdm=marker

" General configuration {{{
    set nocompatible    " Required, fix lot of stuff
    filetype off        " Detect the type of a file based on its name (Vundle needs it to be set to off)
    syntax on           " Enable syntax highlighting

    let mapleader="\<Space>"    " remap mapleader to space

    " :W save file with sudo permissions
    command! W w !sudo tee % > /dev/null

    " Allow to change buffer even if the current one is not written
    set hidden

    " Better command-line completion
    set wildmenu
    set wildmode=longest,list,full

    " Show partial commands in the last line of the screen
    set showcmd

    " Allow backspacing over autoindent, line breaks and start of insert action
    set backspace=indent,eol,start

    " When opening a new line and no filetype-specific indenting is enabled, keep
    " the same indent as the line you're currently on. Useful for READMEs, etc.
    set autoindent

    " Stop certain movements from always going to the first character of a line.
    " While this behaviour deviates from that of Vi, it does what most users
    " coming from other editors would expect.
    set nostartofline

    " Display the cursor position on the last line of the screen or in the status
    " line of a window
    set ruler

    " Always display the status line, even if only one window is displayed
    set laststatus=2

    " Instead of failing a command because of unsaved changes, instead raise a
    " dialogue asking if you wish to save changed files.
    set confirm

    " Use visual bell instead of beeping when doing something wrong
    set visualbell

    " And reset the terminal code for the visual bell. If visualbell is set, and
    " this line is also included, vim will neither flash nor beep. If visualbell
    " is unset, this does nothing.
    "set t_vb=

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

    " Use <F11> to toggle between 'paste' and 'nopaste'
    set pastetoggle=<F11>

    " highlight current line
    set cursorline

    " <C-a> and <C-x> also increase/decrease letters characters
    set nrformats+=alpha

    " set the working directory to the current file's directory
    autocmd BufEnter * lcd %:p:h

    " set some mapping to work with an azerty keyboard
    set langmap+=à@,ù%

    " change the current directory when openning a new file
    autocmd BufEnter * silent! lcd %:p:h

    " automatically reload file when its modified outside vim 
    set autoread

    " Allows vim to record more lines in history
    set history=500
"}}}
" Plugins {{{
    " Manage plugins with vim-plug (https://github.com/junegunn/vim-plug)
    " to install execute:
    " curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
    call plug#begin('~/.vim/plugged')

    " vim-scripts/editorconfig-vim: detects files type and has an accorded behaviour {{{
        Plug 'vim-scripts/editorconfig-vim'
    "}}}
    " nablaa/vim-rainbow-parenthesis: matching parenthesis are coloured{{{
        Plug 'nablaa/vim-rainbow-parenthesis'
    "}}}
    " jiangmiao/auto-pairs: insert or delete brackets, parens, quotes in pair{{{
        Plug 'jiangmiao/auto-pairs'
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
    " scrooloose/nerdtree " Easily navigate through files, see ":h NERD_tree.tx: for help{{{
        Plug 'scrooloose/nerdtree'

        let NERDTreeShowHidden=1    " show hidden files
        let NERDTreeHijackNetrw=1   " behave as a split explorer like netrw
        let NERDTreeShowBookmarks=1 " show bookmarks on opening
        noremap - :NERDTreeToggle <CR> " NERD_tree usage
        
        "map d<CR> <CR> :NERDTree <CR> :bd<CR>
        autocmd BufEnter NERD_tree_* silent! nnoremap d<CR> <CR> :NERDTreeToggle <CR>
        autocmd BufLeave NERD_tree_* silent! unmap d<CR>

        " use gg to go on the line \.. (previous directory) in NERDTree explorer
        autocmd BufEnter NERD_tree_* silent! nnoremap gg /\.\.<CR>
        autocmd BufLeave NERD_tree_* silent! unmap gg
        
        
    "}}}
    " scrooloose/syntastic: Syntax checker{{{
        Plug 'scrooloose/syntastic'

        " this is the recommended configuration (see https://github.com/scrooloose/syntastic/blob/master/README.markdown#3-recommended-settings)

        " Toggle syntastic with <Leader-s>
        nmap <Leader>s :SyntasticToggleMode<CR>

        set statusline+=%#warningmsg#
        set statusline+=%{SyntasticStatuslineFlag()}
        set statusline+=%*

        let g:syntastic_always_populate_loc_list = 1
        let g:syntastic_auto_loc_list            = 1
        let g:syntastic_check_on_open            = 1
        let g:syntastic_check_on_wq              = 0
    "}}}
    " tpope/vim-fugitive: Wrapper for git{{{
        Plug 'tpope/vim-fugitive'

        " make Gdiff vertical split by default
        set diffopt+=vertical
    "}}}
    " bling/vim-airline: status/tab line light as air{{{
        Plug 'bling/vim-airline'

        " appearence configuration
        let g:airline_powerline_fonts = 1
        let g:airline_theme           = 'murmur'

        " features
        let g:airline#extensions#branch#enabled        = 1
        let g:airline#extensions#syntastic#enabled     = 1
        let g:airline#extensions#tabline#enabled       = 1
        let g:airline#extensions#nerdtree#enabled      = 1
        let g:airline#extensions#fugitive#enabled      = 1
        "let g:airline#extensions#vimbufferline#enabled = 1

        " enable modified detection
        let g:airline_detect_modified=1


        " separators symbols
        let g:airline_left_sep          = ''
        let g:airline_left_alt_sep      = ''
        let g:airline_right_sep         = ''
        let g:airline_right_alt_sep     = ''
        "let g:airline_branch_prefix     = ''
        "let g:airline_readonly_symbol   = ''
        "let g:airline_linecolumn_prefix = ''
    "}}}
    " tpope/vim-surround: Surround text with matching caracters{{{
        Plug 'tpope/vim-surround'
    "}}}
    " kana/vim-submode: Create submode (used for windows resizing mappings){{{
        Plug 'kana/vim-submode'
    "}}}
    " junegunn/vim-pseudocl:Pseudo-command-line (experimental) {{{
        Plug 'junegunn/vim-pseudocl'
    "}}}
    " junegunn/vim-oblique: Improved search for Vim.{{{
        Plug 'junegunn/vim-oblique'

        " Clear autocommand
        autocmd! User Oblique
        autocmd! User ObliqueStar
        autocmd! User ObliqueRepeat

        " Put the cursor in the middle of the screen at each match
        autocmd User Oblique       normal! zz
        autocmd User ObliqueStar   normal! zz
        autocmd User ObliqueRepeat normal! zz
    "}}}
    " kien/ctrlp.vim: fuzzy finder for files, buffers and mru{{{
        "Plug 'kien/ctrlp.vim'

        " mapping to open control p
        "let g:ctrlp_map = '<c-p>'
        "let g:ctrlp_cmd = 'CtrlP'

        " ra= the nearest ancestor that contains one version control repo file
        " but only if the current working directory outside of CtrlP is not a direct ancestor of the directory of the current file.
        "let g:ctrlp_working_path_mode = 'ra'

       " open CtrlP bookmarks
       " nnoremap <C-b> :CtrlPBookmarkDir <CR>
        " Bookmark the current directory
       " nnoremap <C-n><C-b> :CtrlPBookmarkDirAdd ./
 
    "}}}
    " nanotech/jellybeans.vim: Cool colorscheme{{{
        Plug 'nanotech/jellybeans.vim'
    "}}}
    " haya14busa/incsearch.vim:incrementally highlights ALL pattern matches unlike default 'incsearch'{{{
        Plug 'haya14busa/incsearch.vim'
    " }}}
    " junegunn/goyo.vim: Make vim disctration less{{{
        Plug 'junegunn/goyo.vim'
    "}}}
    " statox/betterTabs.voim : separate buffers under tabs{{{
        Plug 'statox/betterTabs.vim'
    "}}}
    " vim-pandoc/vim-pandoc: Pandonc document converter integration{{{
        if version >= 704
            Plug 'vim-pandoc/vim-pandoc'
        endif
    "}}}
    " vim-pandoc/vim-pandoc-syntax: Syntax file for pandoc markdown{{{
        Plug 'vim-pandoc/vim-pandoc-syntax'
    "}}}
    " tpope/vim-scriptease: A plugin to create plugins{{{
        Plug 'tpope/vim-scriptease'
    "}}}
    " Snippets pluggins: Group dependencies, vim-snippets depends on ultisnips{{{
        if has('python')
            Plug 'SirVer/ultisnips' | Plug 'honza/vim-snippets'    

            " Trigger snippets with the keys next to "1" on azerty keyboards
            let g:UltiSnipsExpandTrigger="œ"
            let g:UltiSnipsListSnippets="<c-œ>"
            let g:UltiSnipsJumpForwardTrigger="<c-b>"
            let g:UltiSnipsJumpBackwardTrigger="<c-z>"
        endif
    "}}}

    call plug#end()

    " matchit: expand matching text objects{{{
        runtime macros/matchit.vim
    "}}}
    " netrw: The builtin file explorer{{{

        "use tree view
        "let g:netrw_liststyle=3 " Bad idea thats actually pretty bugged

        " open netrw more easily
        "noremap <Leader>o :Explore <CR>
    "}}}
"}}}
" Mappings {{{
    " <C-L> turn off search highlighting until the next search {{{
        nnoremap <C-L> :nohl<CR><C-L>
    "}}}
    " <C-Y> in insert mode will past like p in normal mode {{{
        inoremap <C-Y> <C-O>p
    "}}}
    " When a line is longer than the screen j and k behave like its different lines {{{
        nnoremap j gj
        nnoremap k gk
    "}}}
    " Fast save and quit {{{
        "noremap <Leader>w     :w<CR> :echo "saving"<CR>
        noremap <Leader>x     :x<CR>
        noremap <Leader>q     :q<CR>
    "}}}
    " Make G gg going at the end and begin of the line {{{
        "noremap G G$
        "noremap gg gg0
    "}}}
    " Go to 80column {{{
        noremap <Leader><tab> 80\|
    "}}}
    " In visual mode use A to select all of the file {{{
        vnoremap aa <esc>gg0vG$
    "}}}
    " Quickly redefine mapping {{{
        nnoremap <Leader>r :nnoremap <lt>Leader>t 
    "}}}
    " Easier clipboard access {{{
        nnoremap <Leader>y "*y
        nnoremap <Leader>p "*p
        nnoremap <Leader>P "*P
    "}}}
    " Quickly escape insert mode with jj {{{
        inoremap jj <Esc>
        inoremap jk <Esc>:w<CR>
        " Let's try it in normal mode too
        nnoremap  <Leader>jk <Esc>:w<cr>:echo "saving"<CR>
    "}}}
    " Quickly insert an empty new line without entering insert mode {{{
        nnoremap <Leader>o o<Esc>0D
        nnoremap <Leader>O O<Esc>0D
    "}}}
    " insert newline in normal mode {{{
        nnoremap <Leader><CR> i<CR><esc>
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
    " Use T in visual mode to start Tabular function {{{
        vnoremap T :Tabular / 
    "}}}
    " Use gp to select last pasted text {{{
        nnoremap gp '[v']
    "}}}
"}}}
" Abbreviations {{{
    " Open help vertically with H or HR {{{
        cnoreabbrev HL vert h
        cnoreabbrev H vert bo h
    "}}}
"}}}
" Manage tabs {{{
    " move to new/previous tabs
    noremap <Leader><Leader>l  :tabn<CR>
    noremap <Leader><Leader>h  :tabp<CR>
    " open/close tab
    noremap <Leader><Leader>t  :tabnew<CR>
    noremap <Leader>tc         :tabclose<CR>
    " move current tab to left/right
    noremap <Leader><Leader><Left> :execute 'silent! tabmove ' . (tabpagenr()-2)<CR>
    noremap <Leader><Leader><Right> :execute 'silent! tabmove ' . tabpagenr()<CR>

    "noremap <Leader><Leader><Left>  :execute 'silent! tabmove -1'<CR>
    "noremap <Leader><Leader><Right> :execute 'silent! tabmove +1'<CR>
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
" Manage windows {{{
    " Create a submode to handle windows
    " The submode is entered whith <Leader>k and exited with <Leader>
    call submode#enter_with('WindowsMode', 'n', '', '<Leader>k', ':echo "windows mode"<CR>')
    call submode#leave_with('WindowsMode', 'n', '', '<Leader>')
    " Change of windows with hjkl
    call submode#map('WindowsMode', 'n', '', 'j', '<C-w>j')
    call submode#map('WindowsMode', 'n', '', 'k', '<C-w>k')
    call submode#map('WindowsMode', 'n', '', 'h', '<C-w>h')
    call submode#map('WindowsMode', 'n', '', 'l', '<C-w>l')
    " Resize windows with <C-hjkl>
    call submode#map('WindowsMode', 'n', '', '<C-j>', '<C-w>-')
    call submode#map('WindowsMode', 'n', '', '<C-k>', '<C-w>+')
    call submode#map('WindowsMode', 'n', '', '<C-h>', '<C-w><')
    call submode#map('WindowsMode', 'n', '', '<C-l>', '<C-w>>')
    " Move windows with <S-hjkl>
    call submode#map('WindowsMode', 'n', '', '<S-j>', '<C-w>J')
    call submode#map('WindowsMode', 'n', '', '<S-k>', '<C-w>K')
    call submode#map('WindowsMode', 'n', '', '<S-h>', '<C-w>H')
    call submode#map('WindowsMode', 'n', '', '<S-l>', '<C-w>L')
    " close a window with q
    call submode#map('WindowsMode', 'n', '', 'q', '<C-w>c')
    " split windows with / and !
    call submode#map('WindowsMode', 'n', '', '/', '<C-w>s')
    call submode#map('WindowsMode', 'n', '', '!', '<C-w>v')
 
    let g:submode_keep_leaving_key = 1
    let g:submode_timeout = 0
"}}}
" Color the 81st column when your line is too long {{{
    highlight ColorColumn ctermbg=magenta
    call matchadd('ColorColumn', '\%81v', 100)
"}}}
" Color configuration {{{
    try
        set background=dark
        "let g:solarized_italic=0    "disable solarized italic which is messy with gvim
        colorscheme jellybeans
    catch
        echo "Colorscheme not found"
    endtry
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
    set ai "Auto indent
    set si "Smart indent
    set wrap "Wrap lines
"}}}
" Set up smarter search behaviour {{{
    set incsearch   " Lookahead as search pattern is specified
    set ignorecase  " Ignore case in all searches...
    set smartcase   " unless uppercase letters used
    set hlsearch    " Highlight all matches
                    " use <C-L> to temporarily turn off highlighting

    highlight clear Search

    " This rewires n and N to do the highlighing...
    nnoremap <silent> n   n:call HLNext(0.1)<cr>
    nnoremap <silent> N   N:call HLNext(0.1)<cr>

    " Highlighting function
    function! HLNext (blinktime)
        highlight WhiteOnRed ctermfg=white ctermbg=red
        let [bufnum, lnum, col, off] = getpos('.')
        let matchlen = strlen(matchstr(strpart(getline('.'),col-1),@/))
        let target_pat = '\c\%#\%('.@/.'\)'
        let ring = matchadd('WhiteOnRed', target_pat, 101)
        redraw
        exec 'sleep ' . float2nr(a:blinktime * 1000) . 'm'
        call matchdelete(ring)
        redraw
    endfunction
"}}}
"Maximize windows of gvim {{{
    autocmd GUIEnter * simalt ~n

    set guioptions-=m  "remove menu bar
    set guioptions-=T  "remove toolbar
    set guioptions-=r  "remove right-hand scroll bar
    set guioptions-=L  "remove left-hand scroll bar
"}}}
" Source a local vimrc {{{
    if has('win32')
        let $MYLOCALVIMRC = $HOME . "/_local.vim"
    else
        let $MYLOCALVIMRC = $HOME . "/.local.vim"
    endif

    if filereadable($MYLOCALVIMRC)
        source $MYLOCALVIMRC
    else
        echom "local vimrc does not exists"
    endif
" }}} 
" Rename TMUX tab vim name of edited file {{{
    autocmd BufReadPost,FileReadPost,BufNewFile,BufEnter * call system("tmux rename-window '" . expand("%:t") . "'")
" }}}
" Get a link to the online page of an help tag {{{
    function! GetOnlineDoc(string)

        " Go to specified help tag locally
        execute "h " . a:string

        " Get the help filename without the ".txt" extension
        let filename = expand("%:t:r")

        " Create the link
        let link = "http://vimdoc.sourceforge.net/htmldoc/" . filename . ".html#" . a:string

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
" Misc. not used anymore or to improve {{{
    " Spelling {{{
        "" /!\ Do not forget to get the dictionnaries files in ~/.vim/spell
        "" wget http://ftp.vim.org/vim/runtime/spell/en.utf-8.sug
        "" wget http://ftp.vim.org/vim/runtime/spell/en.utf-8.spl

        "" (un)set english dictionnary with F7
        "map     <silent> <F7> "<Esc>:silent setlocal spell! spelllang=en<CR>"
        "imap    <silent> <F7> "<Esc>:silent setlocal spell! spelllang=en<CR>"
        "" (un)set french dictionnary with F6
        "map     <silent> <F6> "<Esc>:silent setlocal spell! spelllang=fr<CR>"
        "imap    <silent> <F6> "<Esc>:silent setlocal spell! spelllang=fr<CR>"

        "" next word
        "nmap <Leader>n "<Esc>]s"
        "" prev word
        ""nmap <Leader>b "<Esc>[s"
        "" suggest word correction
        "nmap <Leader>v "<Esc>z="
    "}}}
    " Typo auto correct{{{
        " iabbrev lenght length
    "}}}
    " Toggle visibility of naughty characters (thanks to Damian Conway ) {{{
        " Make naughty characters visible
        " (uBB is right double angle, uB7 is middle dot)

        "exec "set lcs=tab:\uBB\uBB,trail:\uB7,nbsp:~"

        "augroup VisibleNaughtiness
            "autocmd!
            "autocmd BufEnter * set list
            "autocmd BufEnter *.txt set nolist
            "autocmd BufEnter *.vp* set nolist
            "autocmd BufEnter * if !&modifiable
            "autocmd BufEnter * set nolist
            "autocmd BufEnter * endif
        "augroup END
    "}}}
    " Make unwanted chars visible {{{
        "set list
        "set listchars=trail:.
        "set listchars+=eol:$
    "}}}
    " Mappings {{{
        " Map Y to act like D and C, i.e. to yank until EOL, rather than act as yy,
        " which is the default
        "map Y y$

        " % go to the matching text objects and now it also select the lines between the text objects
        "noremap % v%
    "}}}
    " quickly access to commands and searches history "{{{
        "nnoremap : q:i
        "nnoremap / q/i
        "nnoremap ? q?i
    "}}}
    " Make :help appear in a full-screen tab, instead of a window {{{
        "Only apply to .txt files...
        "augroup HelpInTabs
            "autocmd!
            "autocmd BufEnter  *.txt   call HelpInNewTab()
        "augroup END

        """Only apply to help files...
        "function! HelpInNewTab ()
            "if &buftype == 'help'
                ""Convert the help window to a tab
                ""execute "normal \<C-W>T"
                ""Convert the help window to a buffer
                "execute "normal \<C-W>o"
            "endif
        "endfunction

        "function! s:help(subject)
            "let buftype = &buftype
            "let &buftype = 'help'
            "let v:errmsg = ''
            "let cmd = "help " . a:subject
            "silent! execute  cmd
            "if v:errmsg != ''
                "let &buftype = buftype
                "return cmd
            "else
                "call setbufvar('#', '&buftype', buftype)
            "endif
        "endfunction
        "command! -nargs=? -bar -complete=help H execute <SID>help(<q-args>)
    "}}}
"}}}
