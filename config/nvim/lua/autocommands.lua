-- Rename TMUX tabs automatically
local TmuxAG = vim.api.nvim_create_augroup('tmux', { clear = true })
vim.api.nvim_create_autocmd({ 'BufReadPost','FileReadPost','BufNewFile','BufEnter'}, {
    desc = 'Rename TMUX tab with name of edited file',
    pattern = '*',
    group = TmuxAG,
    callback = function() vim.system({"tmux", "rename-window", vim.fn.expand("%:t")}) end
})
vim.api.nvim_create_autocmd({ 'VimLeave' }, {
    desc = 'Reset TMUX tab name when leaving editor',
    pattern = '*',
    group = TmuxAG,
    callback = function() vim.system({"tmux", "set-window", "automatic-rename", "on"}) end
})

-- Highlight text on yank
local YankHighlightAG = vim.api.nvim_create_augroup('YankHighlight', { clear = true })
vim.api.nvim_create_autocmd({ 'TextYankPost' }, {
    desc = 'Highlight text on yank',
    pattern = '*',
    group = YankHighlightAG,
    callback = function() vim.highlight.on_yank({ higroup="IncSearch", timeout = 150 }) end
})
