local actions = require("telescope.actions")
local action_layout = require("telescope.actions.layout")

require("telescope").setup {
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
                ["<C-q>"] = actions.send_selected_to_qflist,
                ["<C-a>"] = actions.send_to_qflist
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
                ["<C-q>"] = actions.send_selected_to_qflist,
                ["<C-a>"] = actions.send_to_qflist
            },
        },
    },
    pickers = {
        live_grep = {
            mappings = {
                -- After searching for a word with live_grep use <C-f> to
                -- fuzzy find the files with a result
                i = { ["<C-f>"] = actions.to_fuzzy_refine },
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
