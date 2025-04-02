if vim.fn.has("termguicolors") then
    vim.opt.termguicolors = true
end

vim.g.colorsDefault = "dayfox"
vim.g.colorsDiff = "dayfox"

vim.cmd("colorscheme " .. vim.g.colorsDefault)
