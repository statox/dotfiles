if vim.fn.has('termguicolors') then
    vim.opt.termguicolors = true
end

vim.g.colorsDefault  = 'everforest'
vim.g.colorsDiff     = 'jellybeans'

-- everforest colorscheme configurations
vim.g.everforest_background = 'hard'
vim.g.everforest_sign_column_background = 'none'
vim.g.everforest_better_performance = 1

vim.cmd("colorscheme " .. vim.g.colorsDefault)
