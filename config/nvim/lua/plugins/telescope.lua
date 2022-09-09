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
