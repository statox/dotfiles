local M = {}

function M.skip_or_l()
    local cursor_pos = vim.fn.getpos(".")
    vim.cmd("normal! ^")
    local first_char = vim.fn.getpos(".")

    if cursor_pos[3] < first_char[3] then
        vim.cmd("normal! ^")
    else
        vim.fn.setpos(".", cursor_pos)
        vim.cmd("normal! l")
    end
end

function M.skip_or_h()
    local cursor_pos = vim.fn.getpos(".")
    vim.cmd("normal! ^")
    local first_char = vim.fn.getpos(".")

    if cursor_pos[3] <= first_char[3] then
        vim.cmd("normal! 0")
    else
        vim.fn.setpos(".", cursor_pos)
        vim.cmd("normal! h")
    end
end

return M
