local actions = require("telescope.actions")
local action_layout = require("telescope.actions.layout")

require("telescope").setup({
    defaults = {
        layout_strategy = "center",
        layout_config = {
            center = { width = 0.9, height = 0.3, anchor = "N" },
            horizontal = { width = 0.99, height = 0.98, anchor = "N" },
        },
        prompt_prefix = "🔍 ",
        mappings = {
            n = {
                ["?"] = action_layout.toggle_preview,
                ["<C-j>"] = {
                    actions.move_selection_next,
                    type = "action",
                    opts = { nowait = true, silent = true },
                },
                ["<C-k>"] = {
                    actions.move_selection_previous,
                    type = "action",
                    opts = { nowait = true, silent = true },
                },
                ["<C-q>"] = actions.smart_send_to_qflist + actions.open_qflist,
                ["<Backspace>"] = actions.drop_all,
                ["<C-l>"] = actions.cycle_history_next,
                ["<C-h>"] = actions.cycle_history_prev,
            },
            i = {
                ["?"] = action_layout.toggle_preview,
                ["<C-j>"] = {
                    actions.move_selection_next,
                    type = "action",
                    opts = { nowait = true, silent = true },
                },
                ["<C-k>"] = {
                    actions.move_selection_previous,
                    type = "action",
                    opts = { nowait = true, silent = true },
                },
                ["<C-q>"] = actions.smart_send_to_qflist + actions.open_qflist,
                ["<C-l>"] = actions.cycle_history_next,
                ["<C-h>"] = actions.cycle_history_prev,
            },
        },
    },
    pickers = {
        find_files = {
            layout_strategy = "horizontal",
            path_display = { "truncate" },
        },
        live_grep = {
            layout_strategy = "center",
            mappings = {
                -- After searching for a word with live_grep use <C-f> to
                -- fuzzy find the files with a result
                n = { ["<C-f>"] = actions.to_fuzzy_refine },
                i = { ["<C-f>"] = actions.to_fuzzy_refine },
            },
        },
    },
})

require("telescope").load_extension("fzf")
