"~/.vimrc
" vim:fdm=marker

" General configuration {{{
    filetype plugin indent on  " Detect the type of a file automatically
                               " and use the ftplugin and indent plugin for this ft
    syntax on                  " Enable syntax highlighting

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
    set number norelativenumber

    " Quickly time out on keycodes, but never time out on mappings
    set notimeout ttimeout ttimeoutlen=200

    " set some mapping to work with an azerty keyboard
    set langmap+=à@,ù%

    " automatically reload file when its modified outside vim 
    set autoread

    " Allows vim to record more lines in history
    set history=500

    " Swap and backup files are pretty annoying: get rid of them
    set noswapfile nobackup

    " make autocomplete case sensitive even if 'ignorecase' is on
    set infercase
    set completeopt=longest,menuone,preview

    " Reset path to default and add subdirectories to path
    set path& | let &path .= "**"

    " Show unseeing characters
    set list
    set listchars=eol:$,tab:>-,trail:.

    " Better color handling
    set t_Co=256

    " Show tab line only if there are at least two tab pages
    set showtabline=1
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
    " tpope/vim-surround: Surround text with matching caracters{{{
        Plug 'tpope/vim-surround'
    "}}}
    " nanotech/jellybeans.vim: Cool colorscheme{{{
        Plug 'nanotech/jellybeans.vim'
    "}}}
    " Snippets pluggins: Group dependencies, vim-snippets depends on ultisnips{{{
        if has('python') || has('python3')
            Plug 'SirVer/ultisnips' | Plug 'honza/vim-snippets'

            " Trigger snippets with jj
            inoremap jj <C-R>=UltiSnips#ExpandSnippetOrJump()<CR>
            " Switch between the place holder with arrow keys
            let g:UltiSnipsJumpForwardTrigger="<Right>"
            let g:UltiSnipsJumpBackwardTrigger="<Left>"
            " Make :UltiSnipsEdit split window vertically
            let g:UltiSnipsEditSplit="vertical"
            " Define where the customs plugins are stored
            let g:UltiSnipsSnippetsDir="~/.vim/my-snippets/UltiSnips"

            " Add directory containing my custom plugins
            set runtimepath +=~/.vim/my-snippets
        endif
    "}}}
    " justinmk/vim-dirvish: Directory viewer for vim {{{
        Plug 'justinmk/vim-dirvish'
    " }}}
    " tpope/vim-fugitive: Git wrapper {{{
        Plug 'tpope/vim-fugitive'
    " }}}
    " ctrlpvim/ctrlp.vim: Fuzzy finder {{{
        Plug 'ctrlpvim/ctrlp.vim'
        " Ignore some files/directories
        let g:ctrlp_custom_ignore = {
          \ 'dir':  '\v[\/](platforms|plugins|assets|bin|target|test|lib|font|WEB-INF|svn|node_modules|out|dist)$',
          \ 'file': '\v\.(exe|so|dll)$',
          \ }
        " Dont jump to a buffer when it is already open, instead open another instance
        let g:ctrlp_switch_buffer = 0
        " Be smart with the root directory
        let g:ctrlp_working_path_mode = 'r'
        let g:ctrlp_root_markers = ['pom.xml', '.eslintrc']
    " }}}
    " statox/GOD.vim: Get online doc links {{{
        Plug 'statox/GOD.vim'
    " }}}
    " airblade/vim-gitgutter: show git diff in number gutter {{{
        Plug 'airblade/vim-gitgutter'
    " }}}
    " fcpg/vim-fahrenheit: clean colorscheme {{{
        Plug 'fcpg/vim-fahrenheit'
    " }}}
    Plug 'statox/vim-compare-lines'
    call plug#end()

    " matchit: expand matching text objects{{{
        runtime macros/matchit.vim
    "}}}
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
    " Quickly escape insert mode with jk {{{
        inoremap jk <Esc>:w<CR>
        " Let's try it in normal mode too
        nnoremap  <Leader>jk <Esc>:w<cr>:echo "saving"<CR>
    "}}}
    " Quickly insert an empty new line without entering insert mode {{{
        nnoremap <Leader>o o<Esc>0"_D
        nnoremap <Leader>O O<Esc>0"_D
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
    " Make command line navigation easier {{{
        cnoremap <C-a> USE CTRL - B
        cnoremap <C-l> <Right>
        cnoremap <C-h> <Left>
        cnoremap <C-k> <S-Up>
        cnoremap <C-j> <S-Down>
    "}}}
    " CtrlP mappings {{{
        nnoremap <Leader><CR> :CtrlP<CR>
        nnoremap <Leader>bb :CtrlPBuffer<CR>
        "nnoremap <C-m> :CtrlPMRUFiles<CR>
    " }}}
    " Diff mode mapping {{{
        " Use <C-J> and <C-K> for ]c and [c in diff mode
        nnoremap <expr> <C-J> &diff ? ']c' : '<C-J>'
        nnoremap <expr> <C-K> &diff ? '[c' : '<C-K>'
    "}}}
    " Center next match with <leader>n {{{
        nnoremap <leader>n nzz
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
    noremap <Leader>bd :bd<CR>
    " open buffer with <Leader><Leader>b
    nnoremap <Leader><Leader>b :enew<CR>
"}}}
" Color configuration {{{
    try
        set background=dark
        let g:colorsDefault  = 'fahrenheit'
        let g:colorsDiff     = 'jellybeans'

        execute "colorscheme " . g:colorsDefault
    catch
        echo "Colorscheme not found"
    endtry
"}}}
" Diff configurations {{{
    " Show fille lines, ignore whitespaces in diff
    set diffopt=filler,iwhite

    " Use custom command to create the diff
    set diffexpr=DiffW()

    function! DiffW()
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

    " Easier diff commands
    command! DT execute "colorscheme " . g:colorsDiff | windo diffthis
    command! DO execute "colorscheme " . g:colorsDefault | windo diffoff
    command! DG diffget
    command! DP diffput
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
    set nowrap         " Wrap lines
"}}}
" Set up smarter search behaviour {{{
    set incsearch   " Lookahead as search pattern is specified
    set ignorecase  " Ignore case in all searches...
    set smartcase   " unless uppercase letters used
    set hlsearch    " Highlight all matches
                    " use <C-L> to temporarily turn off highlighting
    set nowrapscan  " Do not go back to first match when searching
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
    augroup tmux
        autocmd!
    autocmd BufReadPost,FileReadPost,BufNewFile,BufEnter * call system("tmux rename-window '" . expand("%:t") . "'")
        autocmd VimLeave * call system("tmux rename-window $(basename $PWD)")
    augroup end
" }}}
" Custom functions and commands {{{
    " Easily quote from the doc {{{
        vnoremap <leader>dy :call QuoteDoc()<CR>
        function! QuoteDoc() range
            " Get lines from the buffer
            let lines=getbufline('%', getpos("'<")[1], getpos("'>")[1])

            " remove the unwanted parts
            let lines[0] = strpart(lines[0], getpos("'<")[2]-1)
            let lines[len(lines)-1] = strpart(lines[len(lines)-1], 0, getpos("'>")[2])

            " For each line
            "   - Replace the leading space by a markdown quotation string
            "   - Escape the unwanted characters
            for i in range(0, len(lines) - 1)
                let lines[i] = substitute(lines[i], '\v\|', '` ', 'g')
                let lines[i] = substitute(lines[i], '\v\*', '` ', 'g')
                let lines[i] = substitute(lines[i], '>$', '\r', 'g')
                let lines[i] = substitute(lines[i], '^<', '\r', 'g')
                let lines[i] = substitute(lines[i], '^\s*', '> ', 'g')
            endfor

            " Put the quoted doc in the clipboard register
            if has('win32')
                let @* = join(lines, "\n")
            else
                let @+ = join(lines, "\n")
            endif
        endfunction
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
    " :PrettyJson prettify json with python {{{
        command! -range PrettyJson <line1>,<line2>!python -m json.tool
    " }}}
"}}}
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
" Fix cursor shape on cygwin {{{
    if has('win32unix')
        let &t_ti.="\e[1 q"
        let &t_SI.="\e[5 q"
        let &t_EI.="\e[1 q"
        let &t_te.="\e[0 q"
    endif
" }}}
