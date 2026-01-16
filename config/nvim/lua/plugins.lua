-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
    local lazyrepo = "https://github.com/folke/lazy.nvim.git"
    local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
    if vim.v.shell_error ~= 0 then
        vim.api.nvim_echo({
            { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
            { out, "WarningMsg" },
            { "\nPress any key to exit..." },
        }, true, {})
        vim.fn.getchar()
        os.exit(1)
    end
end
vim.opt.rtp:prepend(lazypath)

-- Plugin specifications
local plugins = {
    -- colorscheme: the plugin provides both my regular colorscheme and the
    -- one I use for diff mode
    {
        "EdenEast/nightfox.nvim",
        lazy = false,
        priority = 1000,
        opts = {
            options = { dim_inactive = true },
        },
    },

    -- numToStr/Comment.nvim: Smart and powerful comment plugin for
    {
        "numToStr/Comment.nvim",
        config = function()
            require("plugins.comment")
        end,
    },

    -- tpope/vim-surround: Surround text with matching caracters
    { "tpope/vim-surround" },

    -- svermeulen/vim-subversive: Operator motions to perform quick substitutions
    { "svermeulen/vim-subversive" },

    -- godlygeek/tabular: Vim script for text filtering and alignment
    { "godlygeek/tabular" },

    -- tpope/vim-fugitive: Git wrapper
    { "tpope/vim-fugitive" },

    -- mhinz/vim-signify: show git diff in gutter
    { "mhinz/vim-signify" },

    -- statox/GOD.vim: Get online doc links
    { "statox/GOD.vim" },

    -- dependency for some plugins. Installed at top level to access :NvimWebDeviconsHiTest while
    -- evaluating new terminal emulators
    { "nvim-tree/nvim-web-devicons" },

    -- danilamihailov/beacon.nvim: Highlight cursor when it moves
    {
        "danilamihailov/beacon.nvim",
        opts = {
            enabled = function()
                local disabled_ft = { "neo-tree", "help" }
                for _, ft in ipairs(disabled_ft) do
                    if vim.bo.ft == ft then
                        return false
                    end
                end
                return true
            end,
            width = 20,
            min_jump = 1,
            highlight = { bg = "red", ctermbg = 9 },
        },
    },

    -- statox/vim-compare-lines: Compare lines easily
    { "statox/vim-compare-lines" },

    -- lukas-reineke/indent-blankline.nvim: Indent guides
    { "lukas-reineke/indent-blankline.nvim" },

    -- nunjucks templates syntax plugin
    { "Glench/Vim-Jinja2-Syntax" },

    -- modern replacement for matchit
    { "andymass/vim-matchup" },

    -- Run test suites from buffer in terminal buffer
    {
        "vim-test/vim-test",
        config = function()
            require("plugins.vim-test")
        end,
    },

    -- Markdown preview with :MarkdownPreview
    {
        "iamcco/markdown-preview.nvim",
        build = function()
            vim.fn["mkdp#util#install"]()
        end,
    },

    {
        "MeanderingProgrammer/render-markdown.nvim",
        dependencies = {
            "nvim-treesitter/nvim-treesitter",
            "nvim-tree/nvim-web-devicons",
        },
        opts = {
            completions = { lsp = { enabled = true } },
        },
    },

    -- stevearc/aerial.nvim: Opens a split with the symbols of the current file
    -- to help navigating the file quickly
    {
        "stevearc/aerial.nvim",
        opts = {
            layout = {
                -- Determines the default direction to open the aerial window. The 'prefer'
                -- options will open the window in the other direction *if* there is a
                -- different buffer in the way of the preferred direction
                -- Enum: prefer_right, prefer_left, right, left, float
                default_direction = "prefer_left",
            },
        },
    },

    -- nvim-neo-tree/neo-tree.nvim: Filesystem viewer
    {
        "nvim-neo-tree/neo-tree.nvim",
        dependencies = {
            "nvim-lua/plenary.nvim",
            "nvim-tree/nvim-web-devicons",
            "MunifTanjim/nui.nvim",
        },
        config = function()
            require("plugins.neo-tree")
        end,
    },

    -- Nvim Treesitter configurations and abstraction layer
    -- Note: nvim-treesitter docs state it doesn't support lazy-loading
    -- Important! This plugin requires the tree-sitter cli to be installed on system
    -- the version in Ubuntu repository is outdated, instead download from:
    -- https://github.com/tree-sitter/tree-sitter/releases/tag/
    {
        "nvim-treesitter/nvim-treesitter",
        lazy = false,
        build = ":TSUpdate",
        config = function()
            require("plugins.nvim-treesitter")
        end,
    },

    -- nvim-telescope/telescope.nvim: Fuzzy finder
    {
        'nvim-telescope/telescope.nvim',
        dependencies = {
            "nvim-lua/plenary.nvim",
            -- nvim-telescope/telescope-fzf-native.nvim: Implements the FZF algorithm in C
            -- to be used by telescope requires to call load_extension('fzf') after the
            -- telescope setup call
            { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
        },
        config = function()
            require("plugins.telescope")
        end,
    },

    -- neovim/nvim-lspconfig: Configurations for Nvim LSP
    {
        "neovim/nvim-lspconfig",
        dependencies = {
            -- manage external editor tooling such as LSP servers, DAP servers, linters, and formatters
            "williamboman/mason.nvim",
            -- bridge mason.nvim and nvim-lspconfig
            "williamboman/mason-lspconfig.nvim",
        },
        config = function()
            require("plugins.lsp")
        end,
    },

    -- For prettier formating
    {
        "sbdchd/neoformat",
        config = function()
            require("plugins.neoformat")
        end,
    },

    -- hrsh7th/nvim-cmp: Completion engine using different sources
    -- The various completion source plugins are enabled in the plugins/cmp.lua config file
    -- TODO Check if vim-vsnip is really necessary (it is commented in plugins/cmp.lua)
    --      because I don't really use snippets
    {
        "hrsh7th/nvim-cmp",
        dependencies = {
            -- Required dependencies
            "neovim/nvim-lspconfig",
            "hrsh7th/vim-vsnip",
            -- Completion sources
            "hrsh7th/cmp-nvim-lsp",
            "hrsh7th/cmp-buffer",
            "hrsh7th/cmp-path",
            "hrsh7th/cmp-cmdline",
            "hrsh7th/cmp-vsnip",
            "hrsh7th/cmp-calc",
            "hrsh7th/cmp-nvim-lsp-document-symbol",
            "hrsh7th/cmp-nvim-lsp-signature-help",
            "hrsh7th/cmp-nvim-lua",
        },
        config = function()
            require("plugins.cmp")
        end,
    },

    -- use({
    --     "olimorris/codecompanion.nvim",
    --     config = function()
    --         require("codecompanion").setup({
    --             adapters = {
    --                 openai = function()
    --                     return require("codecompanion.adapters").extend("openai", {
    --                         env = {
    --                             -- Use dashlane cli to get the API key
    --                             api_key = "cmd:dcli note 'LLM API Keys for code companion' | sed -n '2p'",
    --                         },
    --                     })
    --                 end,
    --             },
    --
    --             strategies = {
    --                 chat = {
    --                     adapter = "openai",
    --                 },
    --                 inline = {
    --                     adapter = "openai",
    --                 },
    --                 cmd = {
    --                     adapter = "openai",
    --                 }
    --             },
    --         })
    --     end,
    --     dependencies = {
    --         "nvim-lua/plenary.nvim",
    --         "nvim-treesitter/nvim-treesitter",
    --     }
    -- }),
}

-- Setup lazy.nvim
require("lazy").setup(plugins)
