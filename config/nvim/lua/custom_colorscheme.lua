if vim.fn.has("termguicolors") then
    vim.opt.termguicolors = true
end

if os.getenv("LIGHT_THEME") == "1" then
    vim.g.colorsDefault = "dayfox"
    vim.g.colorsDiff = "dayfox"
else
    vim.g.colorsDefault = "nightfox"
    vim.g.colorsDiff = "nordfox"
end

vim.cmd("colorscheme " .. vim.g.colorsDefault)
