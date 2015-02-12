" This vimrc file is freely inspired by several sources:
" URL: http://vim.wikia.com/wiki/Example_vimrc
" URL: https://github.com/amix/vimrc/blob/master/vimrcs/basic.vim
" URL: https://github.com/nobe4/dotfiles/blob/master/.vimrc
" URL: https://github.com/thoughtstream/Damian-Conway-s-Vim-Setup/blob/master/.vimrc


"------------------------------------------------------------
" General configuration

set nocompatible    " Required, fix lot of stuff
filetype off        " Detect the type of a file based on its name (Vundle needs it to be set to off)
syntax on           " Enable syntax highlighting


let mapleader="\<Space>"    " remap mapleader to space

" :W sudo saves the file
" (useful for handling the permission-denied error)
command W w !sudo tee % > /dev/null

" Allows better switching between files
set hidden

" Better command-line completion
set wildmenu

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
set t_vb=

" Enable use of the mouse for all modes
set mouse=a

" Set the command window height to 2 lines, to avoid many cases of having to
" "press <Enter> to continue"
set cmdheight=2

" Display line numbers on the left
set number

" Quickly time out on keycodes, but never time out on mappings
set notimeout ttimeout ttimeoutlen=200

" Use <F11> to toggle between 'paste' and 'nopaste'
set pastetoggle=<F11>


"------------------------------------------------------------
" Vundle : Plugins manager
" see : https://github.com/gmarik/Vundle.vim
"
"/!\ Remember to use 
" git clone https://github.com/gmarik/Vundle.vim.git ~/.vim/bundle/Vundle.vim
" The first time you install vim to avoid error each time you open a file
" Also use
":PluginInstall
":PluginUpdate
":PluginClean
"To install and update plugins

" set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()

" let Vundle manage Vundle, required
Plugin 'gmarik/Vundle.vim'

" detects files type and has an accorded behaviour 
Plugin 'vim-scripts/editorconfig-vim'
" matching parenthesis are coloured
Plugin 'nablaa/vim-rainbow-parenthesis'
" insert or delete brackets, parens, quotes in pair
Plugin 'jiangmiao/auto-pairs'
" Vim plugin for intensely orgasmic commenting
Plugin 'scrooloose/nerdcommenter'
" Vim script for text filtering and alignment
Plugin 'godlygeek/tabular'
" completion with <Tab>
Plugin 'ervandew/supertab'
" Easily navigate through files, see ":h NERD_tree.txt" for help
Plugin 'scrooloose/nerdtree'
" Visually signals the marks
Plugin 'vim-scripts/ShowMarks'

" All of your Plugins must be added before the following line
call vundle#end()            " required
filetype plugin indent on    " required
" To ignore plugin indent changes, instead use:
" "filetype plugin on


"------------------------------------------------------------
" Mappings

" Map Y to act like D and C, i.e. to yank until EOL, rather than act as yy,
" which is the default
map Y y$

" Map <C-L> (redraw screen) to also turn off search highlighting until the
" next search
nnoremap <C-L> :nohl<CR><C-L>

" <C-Y> in insert mode will past like p in normal mode
inoremap <C-Y> <C-O>p i

" % go to the matching brace and now it also select the lines between the braces
noremap % v%

" Swap v and CTRL-V, because Block mode is more useful that Visual mode
"nnoremap    v   <C-V>
"nnoremap <C-V>     v

"vnoremap    v   <C-V>
"vnoremap <C-V>     v

" when a line is longer than the screen j and k behave like its different lines
noremap j gj
noremap k gk

" fast save and quit
noremap <Leader>w     :w<CR> :echo "saving"<CR>
noremap <Leader>x     :x<CR>
noremap <Leader>q     :q<CR>

" make G going at the end of the last line
noremap G G$

"------------------------------------------------------------
" manage windows
" vertical and horizontal splits
noremap <Leader>! <C-w>v
noremap <Leader>/ <C-w>s

" move between windows
noremap <Leader>h <C-w>h
noremap <Leader>j <C-w>j
noremap <Leader>k <C-w>k
noremap <Leader>l <C-w>l


"------------------------------------------------------------
" Color the 81st column when your line is too long
highlight ColorColumn ctermbg=magenta
call matchadd('ColorColumn', '\%81v', 100)


"------------------------------------------------------------
" Color configuration

try
"    syntax enable
"    set background=dark
"    colorscheme solarized
catch
    echo "Colorscheme not found"
endtry


"------------------------------------------------------------
" Text, tab and indent related configuration

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

" automatically wrap text at 80 columns
"set tw=79
"set formatoptions+=t

" Indentation settings for using hard tabs for indent. Display tabs as
" two characters wide.
" set shiftwidth=4
" set tabstop=4


"------------------------------------------------------------
" Spelling

" /!\ Do not forget to get the dictionnaries files in ~/.vim/spell
" wget http://ftp.vim.org/vim/runtime/spell/en.utf-8.sug
" wget http://ftp.vim.org/vim/runtime/spell/en.utf-8.spl

" (un)set english dictionnary with F7
map     <silent> <F7> "<Esc>:silent setlocal spell! spelllang=en<CR>"
imap    <silent> <F7> "<Esc>:silent setlocal spell! spelllang=en<CR>"
" (un)set french dictionnary with F6
map     <silent> <F6> "<Esc>:silent setlocal spell! spelllang=fr<CR>"
imap    <silent> <F6> "<Esc>:silent setlocal spell! spelllang=fr<CR>"

" next word
nmap <Leader>n "<Esc>]s"
" prev word
nmap <Leader>b "<Esc>[s"
" suggest word correction
nmap <Leader>v "<Esc>z="


"------------------------------------------------------------
" NERD_tree configuration

let NERDTreeShowHidden=1    " show hidden files
noremap <Leader>o :NERDTree <CR> " NERD_tree usage


"------------------------------------------------------------
" Set up smarter search behaviour

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


"------------------------------------------------------------
" Toggle visibility of naughty characters (thanks to Damian Conway )
" Make naughty characters visible
" (uBB is right double angle, uB7 is middle dot)

exec "set lcs=tab:\uBB\uBB,trail:\uB7,nbsp:~"

augroup VisibleNaughtiness
 autocmd!
 autocmd BufEnter * set list
 autocmd BufEnter *.txt set nolist
 autocmd BufEnter *.vp* set nolist
 autocmd BufEnter * if !&modifiable
 autocmd BufEnter * set nolist
 autocmd BufEnter * endif
augroup END

"------------------------------------------------------------
" Make :help appear in a full-screen tab, instead of a window

"Only apply to .txt files...
augroup HelpInTabs
    autocmd!
    autocmd BufEnter  *.txt   call HelpInNewTab()
augroup END

"Only apply to help files...
function! HelpInNewTab ()
    if &buftype == 'help'
        "Convert the help window to a tab...
        execute "normal \<C-W>T"
    endif
endfunction
