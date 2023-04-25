local actions = require("telescope.actions")
local action_layout = require("telescope.actions.layout")

require("telescope").setup {
    defaults = {
        layout_strategy = 'center',
        layout_config = {
            center = { width = 0.9, height = 0.5, anchor = "N" }
        },
        prompt_prefix = "🔍 ",
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
                ["<C-q>"] = actions.smart_send_to_qflist + actions.open_qflist,
                ["<Backspace>"] = actions.drop_all
            },
            i = {
                ["?"] = action_layout.toggle_preview,
                ["<C-j>"] = {
                    actions.move_selection_next, type = "action",
                    opts = { nowait = true, silent = true }
                },
                ["<C-k>"] = {
                    actions.move_selection_previous, type = "action",
                    opts = { nowait = true, silent = true }
                },
                ["<C-q>"] = actions.smart_send_to_qflist + actions.open_qflist,
                ["<Backspace>"] = actions.drop_all
            },
        },
    },
    pickers = {
        live_grep = {
            mappings = {
                -- After searching for a word with live_grep use <C-f> to
                -- fuzzy find the files with a result
                n = { ["<C-f>"] = actions.to_fuzzy_refine },
                i = { ["<C-f>"] = actions.to_fuzzy_refine },
            },
        },
    },
}

require('telescope').load_extension('fzf')
