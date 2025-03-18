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


-- Helper function for live_grep_buffers()
local function get_open_buffers()
    local buffers = {}
    for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
        -- Only include buffers that are loaded and listed
        if vim.api.nvim_buf_is_loaded(bufnr) and vim.api.nvim_buf_get_option(bufnr, 'buflisted') then
            local path = vim.api.nvim_buf_get_name(bufnr)
            -- Only include buffers with a valid path
            if path and #path > 0 then
                table.insert(buffers, path)
            end
        end
    end
    return buffers
end

-- Export a module to be able to use the function in the mappings file
return {
    live_grep_buffers = function(...)
        -- live grep only in the currently open buffers
        local args = {...}
        local buffers = get_open_buffers()

        require('telescope.builtin').live_grep({
            search_dirs = buffers,
            prompt_title = "Live Grep Open Buffers",
            cwd = vim.fn.getcwd(),
        })
    end
}
