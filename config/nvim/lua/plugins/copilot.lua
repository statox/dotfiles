-- github/copilot.vim configuration

-- Disable copilot in specific filetypes
vim.g.copilot_filetypes = {
    markdown = false,
}

-- Use <C-n> to accept copilot suggestions
vim.keymap.set('i', '<leader><leader>', 'copilot#Accept("\\<CR>")', {
    expr = true,
    replace_keycodes = false
})
vim.g.copilot_no_tab_map = true
