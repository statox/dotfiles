local actions = require("telescope.actions")
local action_layout = require("telescope.actions.layout")

require("telescope").setup{
    defaults = {
        prompt_prefix = "🔍",
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
    },
}

require('telescope').load_extension('fzf')

local M = {}

function M.grep_prompt()
    require('telescope.builtin').grep_string {
        search = vim.fn.input('Rg> ')
    }
end

function M.my_find_files()
    require('telescope.builtin').grep_string {
        search = vim.fn.input('🔍> ')
    }
end

return M
