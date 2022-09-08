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

    -- nvim-telescope/telescope.nvim: Fuzzy finder
    use {
        'nvim-telescope/telescope.nvim', branch = '0.1.x',
        requires = {
            'nvim-lua/plenary.nvim',
        }
    }

    -- neovim/nvim-lspconfig: Configurations for Nvim LSP
    use 'neovim/nvim-lspconfig'

    -- coc.nvim
    -- use { 'neoclide/coc.nvim', branch = 'release'}
    -- vim.g.coc_disable_startup_warning = 1
    -- vim.g.coc_disable_transparent_cursor = 1
    -- vim.g.coc_global_extensions = {'coc-marketplace', 'coc-json', 'coc-git', 'coc-css', 'coc-prettier', 'coc-tsserver', 'coc-eslint', 'coc-sql', 'coc-html'}

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

local actions = require("telescope.actions")
local action_layout = require("telescope.actions.layout")
require("telescope").setup{
    defaults = {
        mappings = {
            n = {
                ["?"] = action_layout.toggle_preview,
                ["<C-j>"] = {
                    actions.move_selection_next, type = "action",
                    opts = { nowait = true, silent = true }
                },
                ["<C-k>"] = {
                    actions.move_selection_previous, type = "action",
                    opts = { nowait = true, silent = true }
                },
            },
            i = {
                ["<C-j>"] = {
                    actions.move_selection_next, type = "action",
                    opts = { nowait = true, silent = true }
                },
                ["<C-k>"] = {
                    actions.move_selection_previous, type = "action",
                    opts = { nowait = true, silent = true }
                },
            },
        },
    }
}

-- NVIM LSP config
-- Mappings.
-- See `:help vim.diagnostic.*` for documentation on any of the below functions
local opts = { noremap=true, silent=true }
vim.keymap.set('n', '<leader>d', vim.diagnostic.open_float, opts)
vim.keymap.set('n', '[c', vim.diagnostic.goto_prev, opts)
vim.keymap.set('n', ']c', vim.diagnostic.goto_next, opts)
vim.keymap.set('n', '<space>q', vim.diagnostic.setloclist, opts)

-- Use an on_attach function to only map the following keys
-- after the language server attaches to the current buffer
local on_attach = function(client, bufnr)
  -- Enable completion triggered by <c-x><c-o>
  vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')

  -- Mappings.
  -- See `:help vim.lsp.*` for documentation on any of the below functions
  local bufopts = { noremap=true, silent=true, buffer=bufnr }
  vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, bufopts)
  vim.keymap.set('n', 'gd', vim.lsp.buf.definition, bufopts)
  vim.keymap.set('n', 'K', vim.lsp.buf.hover, bufopts)
  vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, bufopts)
  vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, bufopts)
  vim.keymap.set('n', '<space>D', vim.lsp.buf.type_definition, bufopts)
  vim.keymap.set('n', '<space>rn', vim.lsp.buf.rename, bufopts)
  vim.keymap.set('n', '<space>a', vim.lsp.buf.code_action, bufopts)
  vim.keymap.set('n', 'gr', vim.lsp.buf.references, bufopts)
  vim.keymap.set('n', '<space>f', vim.lsp.buf.formatting, bufopts)
end

local lsp_flags = {
  -- This is the default in Nvim 0.7+
  debounce_text_changes = 150,
}
require('lspconfig')['tsserver'].setup{
    on_attach = on_attach,
    flags = lsp_flags,
}
