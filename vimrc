" vim:fdm=marker

" General configuration {{{
    " Reset path to default and add subdirectories to path
    set path& | let &path .= "**"

    filetype plugin indent on  " Detect the type of a file automatically
                               " and use the ftplugin and indent plugin for this ft
    syntax on                  " Enable syntax highlighting

    let mapleader="\<Space>"    " remap mapleader to space
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
    " nanotech/jellybeans.vim: Cool colorscheme (keeping it for the diff mode){{{
        Plug 'nanotech/jellybeans.vim'
    "}}}
    " sainnhe/forest-night: Main colorscheme {{{
        Plug 'sainnhe/forest-night'
    " }}}
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
    " svermeulen/vim-subversive: Operator motions to perform quick substitutions {{{
        Plug 'svermeulen/vim-subversive'
    "}}}
    " tpope/vim-fugitive: Git wrapper {{{
        Plug 'tpope/vim-fugitive'
    " }}}
    " mhinz/vim-signify: show git diff in gutter {{{
        Plug 'mhinz/vim-signify'

        " Customize the appearence of the added lines
        highlight SignifySignAdd ctermbg=darkgreen ctermfg=white cterm=NONE
    " }}}
    " nvim-treesitter/nvim-treesitter {{{
        if (has('nvim'))
            Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}
        endif
    " }}}
    " neoclide/coc.nvim {{{
        Plug 'neoclide/coc.nvim', {'branch': 'release'}
        if !has('nvim')
            let g:coc_disable_startup_warning = 1
        endif
        let g:coc_disable_transparent_cursor = 1
        let g:coc_global_extensions = ['coc-marketplace', 'coc-json', 'coc-git', 'coc-css', 'coc-prettier', 'coc-tsserver', 'coc-eslint', 'coc-sql', 'coc-html']
    " }}}
    " FZF : fuzzy finder {{{
        Plug 'junegunn/fzf', { 'dir': '~/.bin/fzf', 'do': './install --all' }
        Plug 'junegunn/fzf.vim'

        " Change the size of the pop up window used by fzf
        let g:fzf_layout = { 'window': { 'width': 0.9, 'height': 0.8 } }

        " Create a command Agw to match exact word
        command! -bang -nargs=* Agw call fzf#vim#ag(<q-args>, '--word-regexp', <bang>0)

        " Override the command Ag to have a preview window toggled with ?
        command! -bang -nargs=* Ag
          \ call fzf#vim#ag(<q-args>,
          \                 <bang>0 ? fzf#vim#with_preview('up:60%')
          \                         : fzf#vim#with_preview('right:50%:hidden', '?'),
          \                 <bang>0)

        " Override the command File to show a preview window using the preview script shipped with fzf
        command! -bang -nargs=? -complete=dir Files call fzf#vim#files(<q-args>, fzf#vim#with_preview(), <bang>0)
    " }}}
    " sunjon/Shade.nvim: Dim inactive windows {{{
        Plug 'sunjon/Shade.nvim'
        function SetupShadeSettings()
lua <<EOF
require'shade'.setup({
  overlay_opacity = 50,
  opacity_step = 1,
  keys = {
    brightness_up    = '<C-Up>',
    brightness_down  = '<C-Down>',
    toggle           = '<Leader>s',
  }
})
EOF
        endfunction
            augroup ShadeConfig
                autocmd!
                au VimEnter * call SetupShadeSettings()
            augroup END
    " }}}
    " nvim-neo-tree/neo-tree.nvim: Filesystem viewer {{{
        if has('nvim')
            " Dependencies
            Plug 'nvim-lua/plenary.nvim'
            Plug 'kyazdani42/nvim-web-devicons'
            Plug 'MunifTanjim/nui.nvim'
            let g:neo_tree_remove_legacy_commands = 1
            Plug 'nvim-neo-tree/neo-tree.nvim'

            function SetupNeoTreeMappings()
lua <<EOF
require("neo-tree").setup({
window = {
    position = "current",
    mappings = {
        ["-"] = "close_window"
        }
    },
filesystem = {
    window = {
        mappings = {
            ["%"] = "add",
            ["d"] = "add_directory",
            ["D"] = "delete",
            }
        }
    }
})
EOF
            endfunction

            " This is a trick to execute the mappings once the plugin is loaded
            augroup NeoTreeConfig
                autocmd!
                au VimEnter * call SetupNeoTreeMappings()
            augroup END
        endif
    " }}}
    " statox/GOD.vim: Get online doc links {{{
        Plug 'statox/GOD.vim'
    " }}}
    " statox/FYT.vim: highlight text on yank {{{
        if !has('nvim')
        Plug 'statox/FYT.vim'
        else
            augroup YankHighlight
                autocmd!
                autocmd TextYankPost * silent! lua vim.highlight.on_yank {higroup="IncSearch", timeout=150}
            augroup END
        endif
    " }}}
    " statox/vim-compare-lines: Compare lines easily {{{
        Plug 'statox/vim-compare-lines'
    " }}}
    " gelguy/wilder.nvim: Improved wild menu {{{
        " On neovim requires to install pynvim with
        " python3 -m pip install --user --upgrade pynvim
        Plug 'gelguy/wilder.nvim', { 'do': ':UpdateRemotePlugins' }
    " }}}
    " Syntax file plugins {{{
        " posva/vim-vue: syntax file for vuejs {{{
            Plug 'posva/vim-vue'
            let g:vue_pre_processors = ['typescript']
        " }}}
        " Glench/Vim-Jinja2-Syntax: .njk syntax files {{{
            Plug 'Glench/Vim-Jinja2-Syntax'
        " }}}
        " kchmck/vim-coffee-script: Coffee scrupt syntax file {{{
            Plug 'kchmck/vim-coffee-script'
        " }}}
        " HerringtonDarkholme/yats.vim: TS syntax file (useful for tsx files) {{{
            Plug 'HerringtonDarkholme/yats.vim'
        " }}}
        " beyondmarc/glsl.vim: glsl syntax file {{{
            Plug 'beyondmarc/glsl.vim'
        " }}}
        " robbles/logstash.vim: logstash.conf syntax file {{{
            Plug 'robbles/logstash.vim'
        " }}}
        " hashivim/vim-terraform: Syntax support for terraform files {{{
            Plug 'hashivim/vim-terraform'

            " Align settings automatically with Tabularize
            let g:terraform_align=1
            " Automatically format *.tf and *.tfvars on save with `terraform fmt`
            let g:terraform_fmt_on_save=1
        "}}}
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
    " Fast quit {{{
        nnoremap <Leader><S-Q> :qa!<CR>
    "}}}
    " Easier clipboard access {{{
        if has('clipboard')
            xnoremap <Leader>y "+y

            xnoremap <Leader>p "+p
            nnoremap <Leader>p "+p

            xnoremap <Leader><S-p> "+P
            nnoremap <Leader><S-p> "+P
        endif
    "}}}
    " Quickly escape insert mode with jk {{{
        inoremap <silent> jk <Esc>:update<CR>
        nnoremap <silent> <Leader>jk <Esc>:update<cr>
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
        " nnoremap s <C-w>
        if has('nvim')
            let windowHabitsKeys = ["s=", "sv", "ss", "so", "sw", "sh", "sj", "sk", "sl", "s<S-h>", "s<S-j>", "s<S-k>", "s<S-l>", "s<", "s>", "sc"]
            let windowHabitsMessage = ["USE < C-W > INSTEAD", "BREAK BAD HABITS"]
            call breakhabits#createmappings(windowHabitsKeys, windowHabitsMessage)
        endif
    " }}}
    " Make command line navigation easier {{{
        cnoremap <C-l> <Right>
        cnoremap <C-h> <Left>
        cnoremap <C-k> <S-Up>
        cnoremap <C-j> <S-Down>
    "}}}
    " FZF mappings {{{
        nnoremap <Leader><CR> :Files<CR>
        " nnoremap <Leader>bb :Buffers<CR>
        nnoremap <silent> <Leader>bb :Neotree toggle show buffers right<cr>
        " TODO find how to FZF MRU files
        " nnoremap <Leader>br :CtrlPMRUFiles<CR>
        " Start a search with the Ag search with ga
        nnoremap ga :Ag<Space>
        xnoremap ga :<C-u>execute 'Ag ' . expand('<cword>')<CR>

        " :GFS: Shortcut for :GFiles? provided by fzf.vim to get unstaged git files
        " command! GFS GFiles?
        command! GFS Neotree float git_status
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
    " Use ]g and [g to navigate through git hunk thanks to a plugin {{{
        nmap ]g <plug>(signify-next-hunk)
        nmap [g <plug>(signify-prev-hunk)
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
        nnoremap <silent> h :call motion#SkipOrH()<CR>
        nnoremap <silent> l :call motion#SkipOrL()<CR>
    "}}}
    " Explore with - {{{
        nnoremap <silent> - :Neotree toggle focus filesystem %:p<cr>
    " }}}
    " Disable Q to toggle ex mode {{{
        nnoremap Q <nop>
    " }}}
    " vim-subversive mappings {{{
        " Use gc as a word to replace a text object with the content of the unmaned register
        nmap gc  <plug>(SubversiveSubstitute)
        nmap gcc <plug>(SubversiveSubstituteLine)

        nmap <leader>gc  <plug>(SubversiveSubstituteRange)
        xmap <leader>gcc <plug>(SubversiveSubstituteRange)
        nmap <leader>Gc  <plug>(SubversiveSubstituteWordRange)
    " }}}
    " Switch j and k with gj and gk respectively to improve wrapped lines navigation {{{
        nnoremap j gj
        nnoremap k gk
        nnoremap gj j
        nnoremap gk k
    "}}}
    " Sexy comment + yank {{{
        vmap <leader>cY Ygv<leader>cs
    " }}}
    " Buffer-wise jumps with <leader><C-o> and <leader><C-i>: Still under testing {{{
        nnoremap <silent> <leader><C-o> :call jumps#fileCO(v:true)<CR>
        nnoremap <silent> <leader><C-i> :call jumps#fileCO(v:false)<CR>
    " }}}
    " <leader>cd to change the local current directory to the current file {{{
        nnoremap <silent> <leader>cd :lcd %:h<CR>:pwd<CR>
    " }}}
    " Get back the original Y mapping in neovim {{{
        map Y yy
    " }}}
"}}}
" Mapping for terminal mode {{{
    if has('nvim')
        " Switch to normal mode with <Esc>
        tnoremap <Esc> <C-\><C-n>
    endif
" }}}
" Manage tabs {{{
    " open/close tab
    nnoremap <Leader><Leader>t  :tabnew<CR>
    nnoremap <Leader>tc         :tabclose<CR>
    " move current tab to left/right
    nnoremap <Leader><Leader><Left>  :tabmove -1<CR>
    nnoremap <Leader><Leader><Right> :tabmove +1<CR>
    " open a new tab with the current file
    nnoremap <Leader>t% :execute 'tabnew +' . line('.') . ' %'<CR>zz

    " Easily access tabs by index in normal mode with g[number]
    for tabIndex in range(1,8)
        execute 'nnoremap g' . tabIndex . ' ' . tabIndex . 'gt'
    endfor
    " Access the last tab with g9
    nnoremap g9 :tablast<CR>
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
" Treesitter configuration {{{
if has('nvim')
lua <<EOF
require'nvim-treesitter.configs'.setup {
    ensure_installed = { -- one of "all", "maintained" (parsers with maintainers), or a list of languages
        "bash",
        "c",
        "comment",
        "cpp",
        "dockerfile",
        "dot",
        "glsl",
        "go",
        "html",
        "javascript",
        "jsdoc",
        "json",
        "lua",
        "markdown",
        "python",
        "regex",
        "rust",
        "scss",
        "sql",
        "svelte",
        "tsx",
        "typescript",
        "vim",
        "vue",
        "yaml"
    },
    sync_install = false, -- Install parsers synchronously (only applied to `ensure_installed`)
    auto_install = true, -- Automatically install missing parsers when entering buffer
    highlight = {
        enable = true
    },
    incremental_selection = {
        enable = true,
        keymaps = {
            init_selection = "gnn",
            node_incremental = "grn",
            scope_incremental = "grc",
            node_decremental = "grm"
        }
    },
    indent = {
        enable = true
    }
}
EOF
endif
" }}}
" Wilder.nvim configuation {{{
    " Enable the plugin
    call wilder#enable_cmdline_enter()
    " Use both <c-n>/<c-p> and <tab>/<s-tab> to navigate the suggestions
    set wildcharm=<C-n>
    cmap <expr> <C-n> wilder#in_context() ? wilder#next() : "\<c-n>"
    cmap <expr> <C-p> wilder#in_context() ? wilder#previous() : "\<c-p>"
    cmap <expr> <Tab> wilder#in_context() ? wilder#next() : "\<c-n>"
    cmap <expr> <S-Tab> wilder#in_context() ? wilder#previous() : "\<c-p>"
    " Enable wilder in all interesting modes
    call wilder#set_option('modes', ['/', '?', ':'])
    " Enabe fuzzy finding
    call wilder#set_option('pipeline', [
          \   wilder#branch(
          \     wilder#cmdline_pipeline({
          \       'language': 'python',
          \       'fuzzy': 1,
          \     }),
          \     wilder#python_search_pipeline({
          \       'pattern': wilder#python_fuzzy_pattern(),
          \       'sorter': wilder#python_difflib_sorter(),
          \       'engine': 're',
          \     }),
          \   ),
          \ ])
    " When the cmdline is empty, provide suggestions based on the cmdline history
    call wilder#set_option('pipeline', [
          \   wilder#branch(
          \     [
          \       wilder#check({_, x -> empty(x)}),
          \       wilder#history(),
          \     ],
          \     wilder#cmdline_pipeline(),
          \     wilder#search_pipeline(),
          \   ),
          \ ])
    " Change the rendered to show a spinner and the current number of items
    " And use a popupmenu
    if has('nvim')
        call wilder#set_option('renderer', wilder#popupmenu_renderer({
              \ 'highlighter': wilder#basic_highlighter(),
              \ 'separator': ' · ',
              \ 'left': [' ', wilder#wildmenu_spinner(), ' '],
              \ 'right': [' ', wilder#wildmenu_index()],
              \ }))
    endif
" }}}
" Color configuration {{{
    if has('termguicolors')
        set termguicolors
    endif
    try
        let g:colorsDefault  = 'everforest'
        let g:colorsDiff     = 'jellybeans'

        " everforest colorscheme configurations {{{
        let g:everforest_background = 'hard'
        let g:everforest_sign_column_background = 'none'
        let g:everforest_better_performance = 1
        " }}}

        execute "colorscheme " . g:colorsDefault
    catch
        echo "Colorscheme not found"
    endtry
"}}}
" Diff configurations {{{
    " Show file lines, ignore whitespaces in diff
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
"}}}
" Rename TMUX tab vim name of edited file {{{
    augroup tmux
        autocmd!
        autocmd BufReadPost,FileReadPost,BufNewFile,BufEnter * call system("tmux rename-window '" . expand("%:t") . "'")
        autocmd VimLeave * call system('tmux set-window automatic-rename on')
    augroup END
" }}}
" Custom commands {{{
    " :H Open help vertically with H {{{
        command! -complete=help -nargs=1 H call help#VerticalHelp(<f-args>)
    "}}}
    " :W save file with sudo permissions {{{
        command! W w !sudo tee % > /dev/null
    "}}}
    " :E equivalent to :e% {{{
        command! -nargs=? -complete=file E call utils#ReloadOrEdit(<q-args>)
    "}}}
    " :GGUK Shortcut for a plugin command undoing the current git hunk {{{
        command! GGUH SignifyHunkUndo
        command! GGDH SignifyHunkDiff
    " }}}
    " :CountBytes: Count bytes in the buffer {{{
        command! CountBytes echo line2byte(line('$') + 1)
    " }}}
    " Quick alias for :%s {{{
        cnoreabbrev <expr> ss (getcmdtype() == ':' && getcmdline() =~ '^ss$')? '%s//<Left>' : 'ss'
    " }}}
    " Disambiguate fugitive commands {{{
        command! Gblame Git blame
        command! Gl Git pull
        command! Gp Git push
        command! Gc Git commit
        command! Gs Gstatus
        cnoreabbrev <expr> GS (getcmdtype() == ':' && getcmdline() =~ '^GS$')? 'Gs' : 'GS'
        cnoreabbrev <expr> G (getcmdtype() == ':' && getcmdline() =~ '^G$')? 'vertical Git' : 'G'
    " }}}
    " Peek and gp Open the current file in a floating window {{{
    if has('nvim')
    command! P call peek#floating()
    nnoremap gp :P<CR>
    endif
"}}}
" }}}
" Source a local vimrc {{{
    let $MYLOCALVIMRC = $HOME . "/" . (has('win32') ? "_" : ".") . "local.vim"

    if filereadable($MYLOCALVIMRC)
        source $MYLOCALVIMRC
    endif
" }}} 
" Abbreviations for common mispelling {{{
    inoreabbrev syncrho synchro
    inoreabbrev syncrhonize synchronize
    inoreabbrev syncrhonisation synchronisation

    cnoreabbrev <expr> Set (getcmdtype() == ':' && getcmdline() =~ '^Set$')? 'set' : 'Set'
" }}}
