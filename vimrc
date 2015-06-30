"~/.vimrc
" vim:fdm=marker

" General configuration {{{
    set nocompatible    " Required, fix lot of stuff
    filetype off        " Detect the type of a file based on its name (Vundle needs it to be set to off)
    syntax on           " Enable syntax highlighting

    let mapleader="\<Space>"    " remap mapleader to space

    " :W save file with sudo permissions
    command W w !sudo tee % > /dev/null

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
"}}}
" Plugins {{{
    " Manage plugins with vim-plug (https://github.com/junegunn/vim-plug)
    " to install execute:
    " curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
    call plug#begin('~/.vim/plugged')

    " gmarik/Vundle.vim {{{
        " let Vundle manage Vundle, required
        Plug 'gmarik/Vundle.vim'
    "}}}
    " vim-scripts/editorconfig-vim {{{
        " detects files type and has an accorded behaviour 
        "Plug 'vim-scripts/editorconfig-vim'
    "}}}
    " nablaa/vim-rainbow-parenthesis {{{
        " matching parenthesis are coloured
        Plug 'nablaa/vim-rainbow-parenthesis'
    "}}}
    " jiangmiao/auto-pairs {{{
        " insert or delete brackets, parens, quotes in pair
        Plug 'jiangmiao/auto-pairs'
    "}}}
    " scrooloose/nerdcommenter {{{
        " Vim plugin for intensely orgasmic commenting
        Plug 'scrooloose/nerdcommenter'
    "}}}
    " godlygeek/tabular {{{
        " Vim script for text filtering and alignment
        Plug 'godlygeek/tabular'
    "}}}
    " ervandew/supertab {{{
        " completion with <Tab>
        Plug 'ervandew/supertab'
    "}}}
    " scrooloose/nerdtree {{{
        " Easily navigate through files, see ":h NERD_tree.txt" for help
        "Plug 'scrooloose/nerdtree'

        "let NERDTreeShowHidden=1    " show hidden files
        "let NERDTreeHijackNetrw=1   " behave as a split explorer like netrw
        "noremap <Leader>o :NERDTree <CR> " NERD_tree usage

        "map d<CR> <CR> :NERDTree <CR> :bd<CR>
    "}}}
    " scrooloose/syntastic {{{
        " Syntax checker
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
    " altercation/vim-colors-solarized {{{
        " Solarized colorscheme
        Plug 'altercation/vim-colors-solarized'
    "}}}
    " tpope/vim-fugitive {{{
        " Wrapper for git
        Plug 'tpope/vim-fugitive'

        " make Gdiff vertical split by default
        set diffopt+=vertical
    "}}}
    " gregsexton/MatchTag {{{
        " highlight hmtl matching tag
        Plug 'gregsexton/MatchTag'
    "}}}
    " bling/vim-airline {{{
        " status/tab line light as air
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
        let g:airline_branch_prefix     = ''
        let g:airline_readonly_symbol   = ''
        let g:airline_linecolumn_prefix = ''
    "}}}
    " bling/vim-bufferline {{{
        " Show buffers in status line
        "Plug 'bling/vim-bufferline'
        
        "let g:bufferline_modified = '*'
        "let g:bufferline_echo = 1

        "autocmd VimEnter *
                    "\ let &statusline='%{bufferline#refresh_status()}'
                    "\ .bufferline#get_status_string()
    "}}}
    " Yggdroot/indentLine {{{
        " Show lines indent
        Plug 'Yggdroot/indentLine'
    "}}}
    " tpope/vim-surround {{{
        " Surround text with matching caracters
        Plug 'tpope/vim-surround'
    "}}}
    " kana/vim-submode {{{
        " Create submode (used for windows resizing mappings)
        Plug 'kana/vim-submode'
    "}}}
    " tpope/vim-vinegar {{{
        " Improved netrw by Tim Pope
        "Plug 'tpope/vim-vinegar'
    "}}}
    " vim-scripts/SearchComplete {{{
        " auto complete in search mode /
        Plug 'vim-scripts/SearchComplete'
    "}}}
    " junegunn/vim-pseudocl {{{
        "Pseudo-command-line (experimental) 
        Plug 'junegunn/vim-pseudocl'
    "}}}
    " junegunn/vim-oblique {{{
        " Improved search for Vim.
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
    " kien/ctrlp.vim {{{
        " fuzzy finder for files, buffers and mru
        Plug 'kien/ctrlp.vim'

        " mapping to open control p
        let g:ctrlp_map = '<c-p>'
        let g:ctrlp_cmd = 'CtrlP'

        " ra= the nearest ancestor that contains one version control repo file
        " but only if the current working directory outside of CtrlP is not a direct ancestor of the directory of the current file.
        let g:ctrlp_working_path_mode = 'ra'
    "}}}

    call plug#end()

    " matchit {{{
        " expand matching text objects
        runtime macros/matchit.vim
    "}}}
    " netrw {{{
        " The builtin file explorer

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
        noremap j gj
        noremap k gk
    "}}}
    " Fast save and quit {{{
        noremap <Leader>w     :w<CR> :echo "saving"<CR>
        noremap <Leader>x     :x<CR>
        noremap <Leader>q     :q<CR>
    "}}}
    " Make G gg going at the end and begin of the line {{{
        noremap G G$
        noremap gg gg0
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
    "}}}
    " Quickly insert an empty new line without entering insert mode {{{
        nnoremap <Leader>o o<Esc>0D
        nnoremap <Leader>O O<Esc>0D
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
"}}}
" Manage buffers {{{
    " show buffer list and allow to type the buffer name to use with <Leader>bb
    noremap <Leader>bb :ls<CR>:b
    " change buffer with <Leader>bh and <Leader>bl
    noremap <Leader>l :bn<CR>
    noremap <Leader>h :bN<CR>
    " close a buffer with <Leader>bc
    noremap <Leader>bc :bd<CR>
"}}}
" Manage windows {{{
    " vertical and horizontal splits
    noremap <Leader>! <C-w>v
    noremap <Leader>/ <C-w>s
    " move between windows
    "noremap <Leader>h <C-w>h
    noremap <Leader>j <C-w>w
    noremap <Leader>k <C-w>W
    "noremap <Leader>l <C-w>l
    " close a window with <Leader>wc
    noremap <Leader>wc <C-w>c

    " resize wuindows with <Leader>arow key
    " submodes are used to repeat the mapping without hitting the key several times
    call submode#enter_with('grow/shrink', 'n', '', '<leader><UP>', '<C-w>+')
    call submode#enter_with('grow/shrink', 'n', '', '<leader><DOWN>', '<C-w>-')
    call submode#enter_with('grow/shrink', 'n', '', '<leader><LEFT>', '<C-w><')
    call submode#enter_with('grow/shrink', 'n', '', '<leader><RIGHT>', '<C-w>>')
    call submode#map('grow/shrink', 'n', '', '<DOWN>', '<C-w>-')
    call submode#map('grow/shrink', 'n', '', '<UP>', '<C-w>+')
    call submode#map('grow/shrink', 'n', '', '<LEFT>', '<C-w><')
    call submode#map('grow/shrink', 'n', '', '<RIGHT>', '<C-w>>')
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
        let g:solarized_italic=0    "disable solarized italic which is messy with gvim
        colorscheme solarized
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
    set wrap "Wrap lines"
"}}}
" Set up smarter search behaviour {{{
    set incsearch   " Lookahead as search pattern is specified
    set ignorecase  " Ignore case in all searches...
    set smartcase   " unless uppercase letters used
    set hlsearch    " Highlight all matches
                    " use <C-L> to temporarily turn off highlighting

    highlight clear Search
    highlight       Search ctermbg=Yellow

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
" Make :help appear in a full-screen tab, instead of a window {{{
    "Only apply to .txt files...
    augroup HelpInTabs
        autocmd!
        autocmd BufEnter  *.txt   call HelpInNewTab()
    augroup END

    ""Only apply to help files...
    function! HelpInNewTab ()
        if &buftype == 'help'
            "Convert the help window to a tab
            "execute "normal \<C-W>T"
            "Convert the help window to a buffer
            execute "normal \<C-W>o"
        endif
    endfunction

    function! s:help(subject)
        let buftype = &buftype
        let &buftype = 'help'
        let v:errmsg = ''
        let cmd = "help " . a:subject
        silent! execute  cmd
        if v:errmsg != ''
            let &buftype = buftype
            return cmd
        else
            call setbufvar('#', '&buftype', buftype)
        endif
    endfunction
    command! -nargs=? -bar -complete=help H execute <SID>help(<q-args>)
"}}}
"Maximize windows of gvim {{{
    autocmd GUIEnter * simalt ~n

    set guioptions-=m  "remove menu bar
    set guioptions-=T  "remove toolbar
    set guioptions-=r  "remove right-hand scroll bar
    set guioptions-=L  "remove left-hand scroll bar
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

        " insert newline in normal
        "noremap <Leader><CR> i<CR><esc>
    "}}}
"}}}
