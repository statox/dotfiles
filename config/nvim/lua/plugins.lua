-- automatically install and set up packer.nvim
local ensure_packer = function()
    local fn = vim.fn
    local install_path = fn.stdpath('data')..'/site/pack/packer/start/packer.nvim'
    if fn.empty(fn.glob(install_path)) > 0 then
        fn.system({'git', 'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim', install_path})
        vim.cmd [[packadd packer.nvim]]
        return true
    end
    return false
end
local packer_bootstrap = ensure_packer()

require('packer').startup(function(use)
    use 'wbthomason/packer.nvim'

    -- nanotech/jellybeans.vim: Cool colorscheme (keeping it for the diff mode)
    use 'nanotech/jellybeans.vim'
    -- sainnhe/forest-night: Main colorscheme
    use 'sainnhe/forest-night'

    -- scrooloose/nerdcommenter: Vim plugin for intensely orgasmic commenting
    use 'scrooloose/nerdcommenter'
    -- Add whitespace between the comment character and the commented code
    vim.g.NERDSpaceDelims = 1

    -- godlygeek/tabular: Vim script for text filtering and alignment{{{
    use 'godlygeek/tabular'

    -- tpope/vim-surround: Surround text with matching caracters{{{
    use 'tpope/vim-surround'

    -- svermeulen/vim-subversive: Operator motions to perform quick substitutions
    use 'svermeulen/vim-subversive'

    -- tpope/vim-fugitive: Git wrapper
    use 'tpope/vim-fugitive'

    -- mhinz/vim-signify: show git diff in gutter
    use 'mhinz/vim-signify'

    -- statox/GOD.vim: Get online doc links
    use 'statox/GOD.vim'

    -- statox/vim-compare-lines: Compare lines easily
    use 'statox/vim-compare-lines'

    -- sunjon/Shade.nvim: Dim inactive windows
    use 'sunjon/Shade.nvim'

    -- gelguy/wilder.nvim: Improved wild menu
    -- On neovim requires to install pynvim with
    -- python3 -m pip install --user --upgrade pynvim
    -- TODO configure this plugin (For now it shouldn't be enabled)
    use {
        'gelguy/wilder.nvim',
        run = ':UpdateRemotePlugins',
    }

    -- modern replacement for matchit
    use 'andymass/vim-matchup'

    -- Nvim Treesitter configurations and abstraction layer
    use { 'nvim-treesitter/nvim-treesitter', run = ':TSUpdate' }

    -- nvim-neo-tree/neo-tree.nvim: Filesystem viewer
    use {
        'nvim-neo-tree/neo-tree.nvim',
        requires = {
            'nvim-lua/plenary.nvim',
            'kyazdani42/nvim-web-devicons',
            'MunifTanjim/nui.nvim'
        }
    }
    vim.g.neo_tree_remove_legacy_commands = 1

    -- FZF : fuzzy finder
    use { 'junegunn/fzf',  run = 'cd ~/.bin/fzf && ./install --all'}
    use 'junegunn/fzf.vim'
vim.api.nvim_exec([[
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
]],false)

    -- coc.nvim
        use { 'neoclide/coc.nvim', branch = 'release'}
        vim.g.coc_disable_startup_warning = 1
        vim.g.coc_disable_transparent_cursor = 1
        vim.g.coc_global_extensions = {'coc-marketplace', 'coc-json', 'coc-git', 'coc-css', 'coc-prettier', 'coc-tsserver', 'coc-eslint', 'coc-sql', 'coc-html'}

    -- Automatically set up your configuration after cloning packer.nvim
    -- Put this at the end after all plugins
    if packer_bootstrap then
        require('packer').sync()
    end
end)


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
    },
    matchup = {
        enable = true,              -- mandatory, false will disable the whole extension
    },
}

require'shade'.setup({
    overlay_opacity = 50,
    opacity_step = 1,
    keys = {
        brightness_up    = '<C-Up>',
        brightness_down  = '<C-Down>',
        toggle           = '<Leader>s',
    }
})

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
