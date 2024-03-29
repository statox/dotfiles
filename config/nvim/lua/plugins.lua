-- automatically install and set up packer.nvim
local ensure_packer = function()
    local fn = vim.fn
    local install_path = fn.stdpath('data') .. '/site/pack/packer/start/packer.nvim'
    if fn.empty(fn.glob(install_path)) > 0 then
        fn.system({ 'git', 'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim', install_path })
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

    use {
        "EdenEast/nightfox.nvim",
        config = require('nightfox').setup({
            options = {
                dim_inactive = true
            }
        })
    }

    -- numToStr/Comment.nvim: Smart and powerful comment plugin for
    use 'numToStr/Comment.nvim'

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

    -- lukas-reineke/indent-blankline.nvim: Indent guides
    use 'lukas-reineke/indent-blankline.nvim'

    -- gelguy/wilder.nvim: Improved wild menu
    -- On neovim requires to install pynvim with
    -- python3 -m pip install --user --upgrade pynvim
    -- TODO configure this plugin (For now it shouldn't be enabled)
    --[[
       [ use {
       [     'gelguy/wilder.nvim',
       [     run = ':UpdateRemotePlugins',
       [ }
       ]]

    -- modern replacement for matchit
    use 'andymass/vim-matchup'

    -- Markdown preview with :MarkdownPreview
    use({
        "iamcco/markdown-preview.nvim",
        run = function() vim.fn["mkdp#util#install"]() end,
    })

    -- nunjucks templates syntax plugin
    use 'Glench/Vim-Jinja2-Syntax'

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

    -- nvim-telescope/telescope.nvim: Fuzzy finder
    use {
        'nvim-telescope/telescope.nvim', branch = '0.1.x',
        requires = {
            'nvim-lua/plenary.nvim',
        }
    }

    use {
        'nvim-telescope/telescope-fzf-native.nvim',
        run = 'make'
    }

    -- neovim/nvim-lspconfig: Configurations for Nvim LSP
    use {
        'neovim/nvim-lspconfig',
        requires = {
            -- manage external editor tooling such as LSP servers, DAP servers, linters, and formatters
            "williamboman/mason.nvim",
            -- bridge mason.nvim and nvim-lspconfig
            "williamboman/mason-lspconfig.nvim"
        }
    }

    use { 'norcalli/nvim-colorizer.lua', config = function() require('colorizer').setup() end }

    -- stevearc/aerial.nvim: code outline window for skimming and quick navigation
    use {
        'stevearc/aerial.nvim',
        config = function() require('aerial').setup({
            layout = {
                -- Determines the default direction to open the aerial window. The 'prefer'
                -- options will open the window in the other direction *if* there is a
                -- different buffer in the way of the preferred direction
                -- Enum: prefer_right, prefer_left, right, left, float
                default_direction = "prefer_left",
            },
        }) end
    }

    -- For prettier formating
    use 'sbdchd/neoformat'

    -- lukas-reineke/lsp-format.nvim: Autoformating from lsp
    use "lukas-reineke/lsp-format.nvim"

    use 'vim-test/vim-test'

    -- hrsh7th/nvim-cmp: LSP completion
    use {
        'hrsh7th/nvim-cmp',
        requires = {
            -- Required dependencies
            'neovim/nvim-lspconfig',
            'hrsh7th/vim-vsnip',
            -- Completion sources
            'hrsh7th/cmp-nvim-lsp',
            'hrsh7th/cmp-buffer',
            'hrsh7th/cmp-path',
            'hrsh7th/cmp-cmdline',
            'hrsh7th/cmp-vsnip',
            'hrsh7th/cmp-calc',
            'hrsh7th/cmp-nvim-lsp-document-symbol',
            'hrsh7th/cmp-nvim-lsp-signature-help'
        }
    }


    -- Automatically set up your configuration after cloning packer.nvim
    -- Put this at the end after all plugins
    if packer_bootstrap then
        require('packer').sync()
    end
end)

-- Plugins configuration
require 'plugins/nvim-treesitter'
require 'plugins/neo-tree'
require 'plugins/telescope'
require 'plugins/lsp'
require 'plugins/comment'
require 'plugins/vim-test'
-- require 'plugins/wilder'
