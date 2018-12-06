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
    set langmap+=à@,ù%,([,)]

    " automatically reload file when its modified outside vim 
    set autoread

    " Allows vim to record more lines in history
    set history=5000

    " Swap and backup files are pretty annoying: get rid of them
    set noswapfile nobackup

    " make autocomplete case sensitive even if 'ignorecase' is on
    set noinfercase
    set completeopt=longest,menuone,preview

    " Reset path to default and add subdirectories to path
    set path& | let &path .= "**"

    " Show unseeing characters
    set list
    set listchars=eol:$,tab:>-,trail:.

    " Use the modelines (potentially a security concern)
    set modeline

    " Show tab line only if there are at least two tab pages
    set showtabline=1
    " Set up undo dir
    if has("persistent_undo")
        set undodir=~/.undodir/
        set undofile
    endif
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
        let g:ctrlp_root_markers = ['pom.xml', '.eslintrc', '.git']
    " }}}
    " statox/GOD.vim: Get online doc links {{{
        Plug 'statox/GOD.vim'
    " }}}
    " airblade/vim-gitgutter: show git diff in number gutter {{{
        Plug 'airblade/vim-gitgutter'

        " I use my own mappings
        let g:gitgutter_map_keys = 0
    " }}}
    " romainl/vim-editorconfig: yet another plugin for EditorConfig {{{
        Plug 'romainl/vim-editorconfig'
    " }}}
    " statox/gutterline.vim: Show the current lien in the gutter {{{
        set updatetime=50
        let g:GutterLineSign='=>'
        let g:GutterLineIgnore=['help']
        let g:GutterlineHighlightinggroup="DiffAdd"
        Plug 'statox/gutterline.vim'
    " }}}
    " vim-syntastic/syntastic: linter wrapper {{{
        Plug 'vim-syntastic/syntastic'
        let g:syntastic_javascript_checkers=['eslint']
        let g:syntastic_always_populate_loc_list = 1
        let g:syntastic_auto_loc_list = 1
    "}}}
    " markonm/traces.vim: Range, pattern and substitute preview for Vim  {{{
        Plug 'markonm/traces.vim'
    "}}}
    " RRethy/vim-illuminate: Highlight the word under the cursor {{{
        Plug 'RRethy/vim-illuminate'
        let g:Illuminate_delay = 500
        let g:Illuminate_ftblacklist = ['help']
        hi link illuminatedWord Visual
    "}}}
    call plug#end()

    " matchit: expand matching text objects{{{
        runtime macros/matchit.vim
    "}}}
"}}}
" Mappings {{{
    " <C-L> turn off search highlighting until the next search {{{
        nnoremap <C-L> :nohlsearch<CR><C-L>
    "}}}
    " Fast save and quit {{{
        nnoremap <Leader><S-Q> :qa!<CR>
    "}}}
    " Go to 80column {{{
        nnoremap <Leader><tab> 80\|
    "}}}
    " Easier clipboard access {{{
        if has('clipboard')
            if has('win32') || has('win64')
                xnoremap <Leader>y "*y

                xnoremap <Leader>p "*p
                nnoremap <Leader>p "*p

                xnoremap <Leader><S-p> "*P
                nnoremap <Leader><S-p> "*P
            else
                xnoremap <Leader>y "+y

                xnoremap <Leader>p "+p
                nnoremap <Leader>p "+p

                xnoremap <Leader><S-p> "+P
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
        xnoremap T :Tabular / 
    "}}}
    " Use gp to select last pasted text {{{
        nnoremap gp '[v']
    "}}}
    " Delete the current word in insert mode with <C-backspace> {{{
        inoremap  <C-w>
    " }}}
    " Use s instead of <C-w> to handle windows {{{
        nnoremap s <C-w>
    " }}}
    " Make command line navigation easier {{{
        cnoremap <C-l> <Right>
        cnoremap <C-h> <Left>
        cnoremap <C-k> <S-Up>
        cnoremap <C-j> <S-Down>
    "}}}
    " CtrlP mappings {{{
        nnoremap <Leader><CR> :CtrlP<CR>
        nnoremap <Leader>bb :CtrlPBuffer<CR>
    " }}}
    " Diff mode mapping {{{
        " Use <C-J> and <C-K> for ]c and [c in diff mode
        nnoremap <expr> <C-J> &diff ? ']c' : '<C-J>'
        nnoremap <expr> <C-K> &diff ? '[c' : '<C-K>'
    "}}}
    " Center next match with <leader>n {{{
        nnoremap <leader>n nzz
    " }}}
    " Use ]g and [g to navigate through git hunk thanks to gitgutter {{{
        nnoremap ]g :GitGutterNextHunk<CR>
        nnoremap [g :GitGutterPrevHunk<CR>
    " }}}
    " Update GitGutter signs with <leader>g{{{
        nnoremap <leader>g :GitGutter<CR>
    " }}}
    " Search for selected text, forwards or backwards {{{
        xnoremap <silent> # :<C-U>
          \let saveReg=[getreg('"'), getregtype('"')]<CR>
          \gvy?<C-R><C-R>=substitute(escape(@", '?\.*$^~['), '\_s\+', '\\_s\\+', 'g')<CR><CR>
          \gV:call setreg('"', saveReg[0], saveReg[1])<CR>N

        xnoremap <silent> * :<C-U>
          \let saveReg=[getreg('"'), getregtype('"')]<CR>
          \gvy/<C-R><C-R>=substitute(escape(@", '/\.*$^~['), '\_s\+', '\\_s\\+', 'g')<CR><CR>
          \gV:call setreg('"', saveReg[0], saveReg[1])<CR>N
    "}}}
    " Make * and # dont navigate to the next occurence {{{
        nnoremap * *N
        nnoremap # #N
    "}}}
    " make h and l skip indentation white spaces {{{
        nnoremap <silent> h :call motion#MyHMotion()<CR>
        nnoremap <silent> l :call motion#MyLMotion()<CR>
    "}}}
    " Syntastic mappings {{{
        nnoremap <leader>s :SyntasticToggleMode<CR>
    "}}}
"}}}
" Manage tabs {{{
    " move to new/previous tabs
    nnoremap <Leader><Leader>l  :tabnext<CR>
    nnoremap <Leader><Leader>h  :tabprevious<CR>
    " open/close tab
    nnoremap <Leader><Leader>t  :tabnew<CR>
    nnoremap <Leader>tc         :tabclose<CR>
    " move current tab to left/right
    nnoremap <Leader><Leader><Left>  :tabmove -1<CR>
    nnoremap <Leader><Leader><Right> :tabmove +1<CR>
"}}}
" Manage buffers {{{
    " show buffer list and allow to type the buffer name to use with <Leader>bb
    nnoremap gb :ls<CR>:b<space>
    " change buffer with <Leader>bh and <Leader>bl
    nnoremap <Leader>l :bnext<CR>
    nnoremap <Leader>h :bNext<CR>
    " close a buffer with <Leader>bc
    nnoremap <Leader>bd :bdelete<CR>
    " open buffer with <Leader><Leader>b
    nnoremap <Leader><Leader>b :enew<CR>
"}}}
" Color configuration {{{
    try
        let g:colorsDefault  = 'jellybeans'
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
    set diffexpr=diff#DiffW()

    " Easier diff commands
    command! DT execute "colorscheme " . g:colorsDiff | windo diffthis
    command! DO execute "colorscheme " . g:colorsDefault | windo diffoff
    command! DG diffget
    command! DP diffput
"}}}
" status line configuration {{{
    " Always display the status line, even if only one window is displayed
    set laststatus=2

    " Call functions which define buffer variables used in status line
    augroup statusLineVariables
        autocmd!
        " Get the current git branch
        autocmd BufEnter,BufWritePost * call statusline#CurrentGitBranch()
        " Get the git status of the current file
        autocmd BufEnter,BufWritePost * call statusline#CurrentFileGitStatus()
        " Get a formatting of the modification time
        autocmd BufEnter,BufWritePost * call statusline#TimeSinceLastUpdate()
    augroup END

    set statusline=%!statusline#StatusLine()
"}}}
" Text, tab and indent related configuration {{{
    " Use spaces instead of tabs
    set expandtab
    set smarttab

    " 1 tab == 4 spaces
    set shiftwidth=4
    set tabstop=4

    " Linebreak on 500 characters
    set linebreak
    set textwidth=500
    set autoindent
    set smartindent
    set nowrap
"}}}
" Set up smarter search behaviour {{{
    set incsearch   " Lookahead as search pattern is specified
    set ignorecase  " Ignore case in all searches
    set smartcase   " unless uppercase letters used

    " Change the background color of the status line to show if what is being
    " searched has a match or not
    "
    " Define an autocmd to call the HighLightSearch function when we enter the
    " search command line. And a second one to stop the function when we are
    " done searching
    "
    " +timers is required and CmdlineEnter comes with patch1206
    if (has('timers') && has('patch1206'))
        augroup betterSeachHighlighting
            autocmd!
            autocmd CmdlineEnter * if (index(['?', '/'], getcmdtype()) >= 0) | let g:HLSsearching = 1 | call timer_start(1, function('statusline#HighlightSearch', [1])) | endif
            autocmd CmdlineLeave * let g:HLSsearching = 0
        augroup END
    endif
"}}}
"Configuration specific to gvim {{{
    " Maximize window when starting gVim (works on MS windows only)
    augroup GUI
        autocmd!
    autocmd GUIEnter * simalt ~n
    augroup END

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
    augroup END
" }}}
" Custom commands {{{
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
    " :H Open help vertically with H {{{
        command! -complete=help -nargs=1 H call help#VerticalHelp(<f-args>)
    "}}}
    " :W save file with sudo permissions {{{
        command! W w !sudo tee % > /dev/null
    "}}}
    " :QA close all buffers without leaving vim {{{
        command! QA bufdo bd
    "}}}
    " :Ctoggle Toggle quickfix window {{{
        command! Ltoggle call quickfix#ll_toggle()
        command! Ctoggle call quickfix#qf_toggle()
        nnoremap <S-Q> :Ctoggle<CR>
        nnoremap <S-S> :Ltoggle<CR>
    "}}}
    " :GitFilesToStage: Open git changes in the quickfix {{{
        command! GitFTS call git#GetChangesToQF()
    "}}}
    " :QFClosestEntry: Select the entry of the quickfix the closest from the cursor {{{
        command! QFClosestEntry call quickfix#SelectClosestEntry()
    "}}}
" }}}
" Source a local vimrc {{{
    let $MYLOCALVIMRC = $HOME . "/" . (has('win32') ? "_" : ".") . "local.vim"

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
" Startup autocommands {{{
    augroup startup
        autocmd!
        " Open CtrlP when we are in a project directory
        autocmd VimEnter * if (utils#IsProjectDirectory() && argc() == 0) | execute "CtrlP" | endif
    augroup END
" }}}
