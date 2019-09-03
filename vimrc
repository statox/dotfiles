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
    " set langmap+=à@,ù%,([,)]
    set langmap+=à@

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
    set listchars=tab:>-,trail:.

    " Use the modelines (potentially a security concern)
    set modeline

    " Show tab line only if there are at least two tab pages
    set showtabline=1

    " Set up undo dir
    if has("persistent_undo")
        set undodir=~/.undodir/
        set undofile
    endif

    " Reduce update time (useful for GitGutter and COC.nvim)
    set updatetime=300
"}}}
" General configuration - nvim specific {{{
    if (has('nvim'))
        set inccommand=nosplit

        " wildmode=list prevents wildoptions=pum to work
        set wildmode-=list
        set wildoptions=pum
    endif
" }}}
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

        " Add whitespace between the comment character and the commented code
        let NERDSpaceDelims = 1
    "}}}
    " godlygeek/tabular: Vim script for text filtering and alignment{{{
        Plug 'godlygeek/tabular'
    "}}}
    " tpope/vim-surround: Surround text with matching caracters{{{
        Plug 'tpope/vim-surround'
    "}}}
    " nanotech/jellybeans.vim: Cool colorscheme (keeping it for the diff mode){{{
        Plug 'nanotech/jellybeans.vim'
    "}}}
    " AlessandroYorba/Alduin: Another cool colorscheme {{{
        Plug 'AlessandroYorba/Alduin'
    " }}}
    " tpope/vim-fugitive: Git wrapper {{{
        Plug 'tpope/vim-fugitive'
    " }}}
    " statox/GOD.vim: Get online doc links {{{
        Plug 'statox/GOD.vim'
    " }}}
    " airblade/vim-gitgutter: show git diff in number gutter {{{
        Plug 'airblade/vim-gitgutter'

        " I use my own mappings
        let g:gitgutter_map_keys = 0
    " }}}
    " markonm/traces.vim: Range, pattern and substitute preview for Vim  {{{
        if (!has('nvim'))
            Plug 'markonm/traces.vim'
        endif
    "}}}
    " RRethy/vim-illuminate: Highlight the word under the cursor {{{
        Plug 'RRethy/vim-illuminate'
        let g:Illuminate_delay = 500
        let g:Illuminate_ftblacklist = ['help']
        hi link illuminatedWord Visual
    "}}}
    " neoclide/coc.nvim {{{
        Plug 'neoclide/coc.nvim', {'do': { -> coc#util#install()}}
    " }}}
    " HerringtonDarkholme/yats.vim: TS syntax file (better than typescript-vim) {{{
        " Plug 'HerringtonDarkholme/yats.vim'
    " }}}
    " kchmck/vim-coffee-script: Coffee scrupt syntax file {{{
        Plug 'kchmck/vim-coffee-script'
    " }}}
    " romainl/vim-devdocs: Access devdocs.io from vim {{{
        Plug 'romainl/vim-devdocs'
    " }}}
    " FZF : fuzzy finder {{{
        Plug 'junegunn/fzf', { 'dir': '~/.bin/fzf', 'do': './install --all' }
        Plug 'junegunn/fzf.vim'

        " Create a command Agw to match exact word
        command! -bang -nargs=* Agw call fzf#vim#ag(<q-args>, '--word-regexp', <bang>0)

        " Override the command Ag to have a preview window toggled with ?
        command! -bang -nargs=* Ag
          \ call fzf#vim#ag(<q-args>,
          \                 <bang>0 ? fzf#vim#with_preview('up:60%')
          \                         : fzf#vim#with_preview('right:50%:hidden', '?'),
          \                 <bang>0)

        " Override the command File to show a preview window
        command! -bang -nargs=? -complete=dir Files
          \ call fzf#vim#files(<q-args>, fzf#vim#with_preview(), <bang>0)
    " }}}
    " Extempore and rust related plugins {{{
        Plug 'timburgess/extempore.vim'
        " Plug 'eraserhd/parinfer-rust'
    " }}}
    " neovimhaskell/haskell-vim {{{
        Plug 'neovimhaskell/haskell-vim'
    " }}}
    " christoomey/vim-conflicted: Improve the git conflict resolution with vim {{{
        Plug 'christoomey/vim-conflicted'
    " }}}
    " rhysd/git-messenger.vim: Show the git commit for the code under the cursor {{{
        Plug 'rhysd/git-messenger.vim'
    " }}}
    call plug#end()

    " matchit: expand matching text objects{{{
        runtime macros/matchit.vim
    "}}}
"}}}
" Mappings {{{
    " <C-L> turn off search highlighting until the next search {{{
        nnoremap <C-L> :nohlsearch<CR><C-L>
        if (exists(':GitGutter'))
            nnoremap <C-L> :nohlsearch\|GitGutter<CR><C-L>
        endif
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
        inoremap <silent> jk <Esc>:w<CR>
        " Let's try it in normal mode too
        nnoremap <silent> <Leader>jk <Esc>:w<cr>
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
        inoremap  <C-w>
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
    " FZF mappings {{{
        nnoremap <Leader><CR> :Files<CR>
        nnoremap <Leader>bb :Buffers<CR>
        " TODO find how to FZF MRU files
        " nnoremap <Leader>br :CtrlPMRUFiles<CR>
        " Start a search with the Ag search with ga
        nnoremap ga :Ag<Space>
        xnoremap ga :<C-u>execute 'Ag ' . expand('<cword>')<CR>

        " :GFS: Shortcut for :GFiles? provided by fzf.vim to get unstaged git files
        command! GFS GFiles?
    " }}}
    " Diff mode mapping {{{
        " Use <C-J> and <C-K> for ]c and [c in diff mode
        nnoremap <expr> <C-J> &diff ? ']c' : '<C-J>'
        nnoremap <expr> <C-K> &diff ? '[c' : '<C-K>'
    "}}}
    " Center next match with <leader>n {{{
        nnoremap <leader>n nzz
        nnoremap <leader>N Nzz
    " }}}
    " Use ]g and [g to navigate through git hunk thanks to gitgutter {{{
        nnoremap ]g :GitGutterNextHunk<CR>
        nnoremap [g :GitGutterPrevHunk<CR>
    " }}}
    " Update GitGutter signs with <leader>g{{{
        nnoremap <leader>gg :GitGutter<CR>
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
    " Explore with - {{{
        nnoremap - :Explore<CR>
    " }}}
    " Scroll the window with Shift + Arrow keys {{{
        nnoremap <S-DOWN> <C-e>
        nnoremap <S-UP> <C-y>
    " }}}
    " Vista mappings {{{
        nnoremap <Leader>vc :Vista<CR>
        nnoremap <Leader>vf :Vista finder<CR>
        nnoremap <F2> :Vista!!<CR>
    " }}}
    " Use <Leader>$ to open a new terminal buffer {{{
        nnoremap <silent> <Leader>$ :terminal<CR>
    " }}}
    " Disable Q to toggle ex mode {{{
        nnoremap Q <nop>
    " }}}
    " Quick substitute mappings {{{
        nnoremap <Leader>zq :s/"//g<CR>
        xnoremap <Leader>zq :s/"//g<CR>
        nnoremap <Leader>zw :s/"/'/g<CR>
        xnoremap <Leader>zw :s/"/'/g<CR>
    " }}}
"}}}
" Mapping for terminal mode {{{
    if has('nvim')
        " Switch to normal mode with <Esc>
        tnoremap <Esc> <C-\><C-n>

        " Simulate <C-r> in terminal
        tnoremap <expr> <C-R> '<C-\><C-N>"'.nr2char(getchar()).'pi'

        " Mappings in normal mode only in terminal buffers
        augroup TerminalNormalModeMappings
            autocmd!
            autocmd TermOpen * call SetupTerminalBuffer()
        augroup END

        function! SetupTerminalBuffer()
            call CreateTerminalNormalModeMappings()

            setlocal nonumber norelativenumber
        endfunction

        function! CreateTerminalNormalModeMappings()
            " Open the filename under the cursor in a new tab
            nnoremap <buffer> <Leader>t% :execute 'tabnew ' . expand('<cfile>')<CR>

            " Keys to send to the command from normal mode {{{
            nnoremap <buffer> <C-c> i<C-c>
            nnoremap <buffer> <CR> i<CR>
            nnoremap <buffer> <C-l> i<C-l>
            nnoremap <buffer> <Up> i<Up>
            nnoremap <buffer> q iq
            " }}}
        endfunction
    endif
" }}}
" Manage tabs {{{
    " move to new/previous tabs (Disabled, remove when I removed it from my muscle memory in favor of gt and gT)
    nnoremap <Leader><Leader>l  <nop>
    nnoremap <Leader><Leader>h  <nop>
    " open/close tab
    nnoremap <Leader><Leader>t  :tabnew<CR>
    nnoremap <Leader>tc         :tabclose<CR>
    " move current tab to left/right
    nnoremap <Leader><Leader><Left>  :tabmove -1<CR>
    nnoremap <Leader><Leader><Right> :tabmove +1<CR>
    " open a new tab with the current file
    nnoremap <Leader>t% :execute 'tabnew +' . line('.') . ' %'<CR>zz
"}}}
" Manage buffers {{{
    " show buffer list and allow to type the buffer name to use with <Leader>bb
    nnoremap gb :ls<CR>:b<space>
    " change buffer with <Leader>h and <Leader>l
    nnoremap <Leader>l :bnext<CR>
    nnoremap <Leader>h :bNext<CR>
    " close a buffer with <Leader>bd
    nnoremap <Leader>bd :bdelete<CR>
    " open buffer with <Leader><Leader>b
    nnoremap <Leader><Leader>b :enew<CR>
"}}}
" Color configuration {{{
    try
        let g:colorsDefault  = 'alduin'
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
    " Use our custom status line
    call statusline#SetStatusLine()
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
    augroup betterSeachHighlighting
        autocmd!
        autocmd CmdlineEnter * call search#StartStatuslineHighlighting()
        autocmd CmdlineLeave * call search#StopStatuslineHighlighting()
    augroup END
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
        autocmd VimLeave * call system('tmux set-window automatic-rename on')
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
    " :E equivalent to :e% {{{
        command! E e%
    "}}}
    " :QA close all buffers without leaving vim {{{
        command! QA bufdo bd
    "}}}
    " :GGUK: Shortcut for :GitGutterUndoHunk {{{
        command! GGUH GitGutterUndoHunk
    " }}}
    " :GG: Shortcut for :GitGutter {{{
        command! GG GitGutter
    " }}}
    " :Fold, FoldSyn and Unfold shortcut to folding {{{
        command! Fold setlocal foldnestmax=1 | setlocal foldmethod=indent | normal! zM
        command! FoldSyn setlocal foldnestmax=1 | setlocal foldmethod=syntax | normal! zM
        command! Unfold setlocal foldmethod& foldnestmax& | normal! zR
    " }}}
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
" Abbreviations for common mispelling {{{
    inoreabbrev syncrho synchro
    inoreabbrev syncrhonize synchronize
    inoreabbrev syncrhonisation synchronisation

    cnoreabbrev <expr> Set (getcmdtype() == ':' && getcmdline() =~ '^Set$')? 'set' : 'Set'
" }}}
