if vim.fn.has('termguicolors') then
    vim.opt.termguicolors = true
end

vim.g.colorsDefault = 'nightfox'
vim.g.colorsDiff    = 'nordfox'

vim.cmd("colorscheme " .. vim.g.colorsDefault)
