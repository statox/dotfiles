" This vimrc file is freely inspired by several sources:
" URL: http://vim.wikia.com/wiki/Example_vimrc
" URL: https://github.com/amix/vimrc/blob/master/vimrcs/basic.vim
" URL: https://github.com/nobe4/dotfiles/blob/master/.vimrc



"------------------------------------------------------------
" General configuration

set nocompatible 	"Required, fix lot of stuff
filetype off		"Detect the type of a file based on its name (Vundle needs it to be set to off)
syntax on			" Enable syntax highlighting	


let mapleader="\<Space>"    " remap mapleader to space

" :W sudo saves the file
" " (useful for handling the permission-denied error)
command W w !sudo tee % > /dev/null"

" Allows better switching between files
set hidden	

" Better command-line completion
set wildmenu

" Show partial commands in the last line of the screen
set showcmd



"------------------------------------------------------------
" Color configuration

try
	colorscheme mustang
catch
endtry

" Highlight searches (use <C-L> to temporarily turn off highlighting; see the
" mapping of <C-L> below)
set hlsearch



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


"------------------------------------------------------------
" Vundle : Plugins manager
" see : https://github.com/gmarik/Vundle.vim
"
"/!\ Remember to use 
" git clone https://github.com/gmarik/Vundle.vim.git ~/.vim/bundle/Vundle.vim
" The first time you install vim to avoid error each time you open a file

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



" All of your Plugins must be added before the following line
call vundle#end()            " required
filetype plugin indent on    " required
" To ignore plugin indent changes, instead use:
" "filetype plugin on


"------------------------------------------------------------
" Usability options {{{1

" Use case insensitive search, except when using capital letters
set ignorecase
set smartcase

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
" Indentation options {{{1

" Indentation settings for using hard tabs for indent. Display tabs as
" two characters wide.
" set shiftwidth=4
" set tabstop=4


"------------------------------------------------------------
" Mappings {{{1
"
" Useful mappings

" Map Y to act like D and C, i.e. to yank until EOL, rather than act as yy,
" which is the default
map Y y$

" Map <C-L> (redraw screen) to also turn off search highlighting until the
" next search
nnoremap <C-L> :nohl<CR><C-L>

" <C-Y> in insert mode will past like p in normal mode
inoremap <C-Y> <C-O>p i

" Ctrl+Space autocomplete (yay eclipse)
" (TODO: understand how the heck this mapping works. 
" I found it there: http://stackoverflow.com/questions/510503/ctrlspace-for-omni-and-keyword-completion-in-vim)
inoremap <expr> <C-Space> pumvisible() \|\| &omnifunc == '' ?
            \ "\<lt>C-n>" :
            \ "\<lt>C-x>\<lt>C-o><c-r>=pumvisible() ?" .
            \ "\"\\<lt>c-n>\\<lt>c-p>\\<lt>c-n>\" :" .
            \ "\" \\<lt>bs>\\<lt>C-n>\"\<CR>"
imap <C-@> <C-Space>


"------------------------------------------------------------
