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
        enable = true, -- mandatory, false will disable the whole extension
    },
}
