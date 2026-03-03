-- github/copilot.vim configuration

-- Disable copilot by default
vim.g.copilot_filetypes = {
    ['*'] = false,
    python = true,
}

-- Use <space><space> to accept copilot suggestions
vim.keymap.set('i', '<space><space>', function()
    if vim.fn['copilot#Enabled']() == 1 then
        return vim.fn['copilot#Accept']()
    end
    return vim.api.nvim_replace_termcodes('<leader><leader>', true, false, true)
end, {
        expr = true,
        replace_keycodes = false,
    })

vim.g.copilot_no_tab_map = true
