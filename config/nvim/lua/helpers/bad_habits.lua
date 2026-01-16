-- Module inspired from https://www.statox.fr/posts/2021/03/breaking_habits_floating_window/
-- Usage in mappings.lua file:
--
--     local bad_habits = require('helpers.bad_habits')
--     vim.keymap.set("n", "gc", function() bad_habits.break_habits_window({ "Outdated  mapping", "Use `s` instead" }) end)

local M = {}

function M.break_habits_window(message)
    -- Define the size of the floating window
    local width = 50
    local height = 10

    -- Create the scratch buffer displayed in the floating window
    local buf = vim.api.nvim_create_buf(false, true)

    -- Create the lines to draw a box
    local horizontal_border = '+' .. string.rep('-', width - 2) .. '+'
    local empty_line = '|' .. string.rep(' ', width - 2) .. '|'
    local lines = { horizontal_border }
    for _ = 1, height - 2 do
        table.insert(lines, empty_line)
    end
    table.insert(lines, horizontal_border)
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)

    -- Create the lines for the centered message and put them in the buffer
    for i, line in ipairs(message) do
        local start_col = math.floor((width - #line) / 2)
        local end_col = start_col + #line
        local current_row = math.floor(height / 2 - #message / 2) + i - 1
        vim.api.nvim_buf_set_text(buf, current_row, start_col, current_row, end_col, { line })
    end

    -- Set mappings in the buffer to close the window easily
    local closing_keys = { '<Esc>', '<CR>', '<Leader>' }
    for _, key in ipairs(closing_keys) do
        vim.api.nvim_buf_set_keymap(buf, 'n', key, ':close<CR>', { silent = true, nowait = true, noremap = true })
    end

    -- Create the floating window
    local ui = vim.api.nvim_list_uis()[1]
    local opts = {
        relative = 'editor',
        width = width,
        height = height,
        col = math.floor((ui.width - width) / 2),
        row = math.floor((ui.height - height) / 2),
        anchor = 'NW',
        style = 'minimal',
    }
    local win = vim.api.nvim_open_win(buf, true, opts)

    -- Change highlighting
    vim.api.nvim_set_option_value('winhl', 'Normal:ErrorFloat', { win = win })
end

return M
