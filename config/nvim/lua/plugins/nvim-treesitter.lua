require("nvim-treesitter.configs").setup({
    ensure_installed = "all",
    -- ensure_installed = { -- "all" or a list of languages
    --     "arduino",
    --     "bash",
    --     "c",
    --     "comment",
    --     "cpp",
    --     "csv",
    --     "diff",
    --     "dockerfile",
    --     "dot",
    --     "git_config",
    --     "git_rebase",
    --     "glsl",
    --     "go",
    --     "html",
    --     "javascript",
    --     "jsdoc",
    --     "json",
    --     "lua",
    --     "markdown",
    --     "python",
    --     "regex",
    --     "rust",
    --     "scss",
    --     "sql",
    --     "svelte",
    --     "tsx",
    --     "typescript",
    --     "vim",
    --     "vue",
    --     "yaml",
    -- },
    sync_install = false, -- Install parsers synchronously (only applied to `ensure_installed`)
    auto_install = true, -- Automatically install missing parsers when entering buffer
    highlight = {
        enable = true,
    },
    incremental_selection = {
        enable = true,
        keymaps = {
            init_selection = "gnn",
            node_incremental = "grn",
            scope_incremental = "grc",
            node_decremental = "grm",
        },
    },
    indent = {
        enable = true,
    },
    matchup = {
        enable = true, -- mandatory, false will disable the whole extension
    },
})
