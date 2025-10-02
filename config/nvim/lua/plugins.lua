-- automatically install and set up packer.nvim
local ensure_packer = function()
    local fn = vim.fn
    local install_path = fn.stdpath("data") .. "/site/pack/packer/start/packer.nvim"
    if fn.empty(fn.glob(install_path)) > 0 then
        fn.system({ "git", "clone", "--depth", "1", "https://github.com/wbthomason/packer.nvim", install_path })
        vim.cmd([[packadd packer.nvim]])
        return true
    end
    return false
end
local packer_bootstrap = ensure_packer()

require("packer").startup(function(use)
    use("wbthomason/packer.nvim")

    -- colorscheme: the plugin provides both my regular colorscheme and the
    -- one I use for diff mode
    use({
        "EdenEast/nightfox.nvim",
        config = require("nightfox").setup({
            options = {
                dim_inactive = true,
            },
        }),
    })

    -- numToStr/Comment.nvim: Smart and powerful comment plugin for
    use("numToStr/Comment.nvim")

    -- tpope/vim-surround: Surround text with matching caracters{{{
    use("tpope/vim-surround")

    -- svermeulen/vim-subversive: Operator motions to perform quick substitutions
    use("svermeulen/vim-subversive")

    -- godlygeek/tabular: Vim script for text filtering and alignment{{{
    use("godlygeek/tabular")

    -- tpope/vim-fugitive: Git wrapper
    use("tpope/vim-fugitive")

    -- mhinz/vim-signify: show git diff in gutter
    use("mhinz/vim-signify")

    -- statox/GOD.vim: Get online doc links
    use("statox/GOD.vim")

    -- danilamihailov/beacon.nvim: Highlight cursor when it moves
    use({
        "danilamihailov/beacon.nvim",
        config = function()
            require("beacon").setup({
                enabled = function()
                    local disabled_ft = { "neo-tree", "help" }
                    for _, ft in ipairs(disabled_ft) do
                        if vim.bo.ft == ft then
                            return false
                        end
                    end
                    return true
                end,
                width = 20, --- integer width of the beacon window
                min_jump = 1, --- integer what is considered a jump. Number of lines
                highlight = { bg = "red", ctermbg = 9 }, -- vim.api.keyset.highlight table passed to vim.api.nvim_set_hl
            })
        end,
    })

    -- statox/vim-compare-lines: Compare lines easily
    use("statox/vim-compare-lines")

    -- lukas-reineke/indent-blankline.nvim: Indent guides
    use("lukas-reineke/indent-blankline.nvim")

    -- nunjucks templates syntax plugin
    use("Glench/Vim-Jinja2-Syntax")

    -- modern replacement for matchit
    use("andymass/vim-matchup")

    -- norcalli/nvim-colorizer.lua: Provides a function to colorize RGB and CSS colors in buffer
    use({
        "norcalli/nvim-colorizer.lua",
        config = function()
            require("colorizer").setup()
        end,
    })

    -- Run test suites from buffer in terminal buffer
    use("vim-test/vim-test")

    -- Markdown preview with :MarkdownPreview
    use({
        "iamcco/markdown-preview.nvim",
        run = function()
            vim.fn["mkdp#util#install"]()
        end,
    })
    use({
        'MeanderingProgrammer/render-markdown.nvim',
        after = { 'nvim-treesitter' },
        -- requires = { 'nvim-mini/mini.nvim', opt = true }, -- if you use the mini.nvim suite
        -- requires = { 'nvim-mini/mini.icons', opt = true }, -- if you use standalone mini plugins
        requires = { 'nvim-tree/nvim-web-devicons', opt = true }, -- if you prefer nvim-web-devicons
        config = function()
            require('render-markdown').setup({})
        end,
    })

    -- stevearc/aerial.nvim: Opens a split with the symbols of the current file
    -- to help navigating the file quickly
    use({
        "stevearc/aerial.nvim",
        config = function()
            require("aerial").setup({
                layout = {
                    -- Determines the default direction to open the aerial window. The 'prefer'
                    -- options will open the window in the other direction *if* there is a
                    -- different buffer in the way of the preferred direction
                    -- Enum: prefer_right, prefer_left, right, left, float
                    default_direction = "prefer_left",
                },
            })
        end,
    })

    -- nvim-neo-tree/neo-tree.nvim: Filesystem viewer
    use({
        "nvim-neo-tree/neo-tree.nvim",
        requires = {
            "nvim-lua/plenary.nvim",
            "nvim-tree/nvim-web-devicons",
            "MunifTanjim/nui.nvim",
        },
    })

    -- Nvim Treesitter configurations and abstraction layer
    use({ "nvim-treesitter/nvim-treesitter", run = ":TSUpdate" })

    -- nvim-telescope/telescope.nvim: Fuzzy finder
    use({
        "nvim-telescope/telescope.nvim",
        branch = "0.1.x",
        requires = {
            "nvim-lua/plenary.nvim",
            "nvim-telescope/telescope-fzf-native.nvim",
        },
    })

    -- nvim-telescope/telescope-fzf-native.nvim: Implements the FZF algorithm in C
    -- to be used by telescope requires to call load_extension('fzf') after the
    -- telescope setup call
    use({
        "nvim-telescope/telescope-fzf-native.nvim",
        run = "make",
    })

    -- neovim/nvim-lspconfig: Configurations for Nvim LSP
    use({
        "neovim/nvim-lspconfig",
        requires = {
            -- manage external editor tooling such as LSP servers, DAP servers, linters, and formatters
            "williamboman/mason.nvim",
            -- bridge mason.nvim and nvim-lspconfig
            "williamboman/mason-lspconfig.nvim",
        },
    })

    -- For prettier formating
    use("sbdchd/neoformat")

    -- hrsh7th/nvim-cmp: Completion engine using different sources
    -- The various completion source plugins are enabled in the plugins/cmp.lua config file
    -- TODO Check if vim-vsnip is really necessary (it is commented in plugins/cmp.lua)
    --      because I don't really use snippets
    use({
        "hrsh7th/nvim-cmp",
        requires = {
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
    })

    use({
        "olimorris/codecompanion.nvim",
        config = function()
            require("codecompanion").setup({
                adapters = {
                    openai = function()
                        return require("codecompanion.adapters").extend("openai", {
                            env = {
                                -- Use dashlane cli to get the API key
                                api_key = "cmd:dcli note 'LLM API Keys for code companion' | sed -n '2p'",
                            },
                        })
                    end,
                },

                strategies = {
                    chat = {
                        adapter = "openai",
                    },
                    inline = {
                        adapter = "openai",
                    },
                    cmd = {
                        adapter = "openai",
                    }
                },
            })
        end,
        requires = {
            "nvim-lua/plenary.nvim",
            "nvim-treesitter/nvim-treesitter",
        }
    })

    -- Automatically set up your configuration after cloning packer.nvim
    -- Put this at the end after all plugins
    if packer_bootstrap then
        require("packer").sync()
    end
end)

-- Plugins configuration
require("plugins/nvim-treesitter")
require("plugins/neo-tree")
require("plugins/telescope")
require("plugins/lsp")
require("plugins/cmp")
require("plugins/comment")
require("plugins/vim-test")
require("plugins/neoformat")
