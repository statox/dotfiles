--qf.vim

vim.opt_local.wrap = false
vim.opt_local.relativenumber = false
vim.opt_local.number = true

-- we don't want quickfix buffers to pop up when doing :bn or :bp
vim.opt.buflisted = false

-- Easily navigate quickfix with ]q and [q
vim.keymap.set("n", "]q", ":cnext<CR>zz", { noremap = true, silent = true })
vim.keymap.set("n", "[q", ":cprevious<CR>zz", { noremap = true, silent = true })
-- Quick window resize
vim.keymap.set("n", "-", ":10wincmd -<CR>", { noremap = true, silent = true, buffer = true })
vim.keymap.set("n", "+", ":10wincmd +<CR>", { noremap = true, silent = true, buffer = true })

local QuickFixAG =
    vim.api.nvim_create_augroup("quickfix", { clear = true }), vim.api.nvim_create_autocmd({ "QuickFixCmdPost" }, {
        desc = "Automatically open quickfix window",
        group = QuickFixAG,
        pattern = "[^l]*",
        command = "cwindow",
    })

vim.api.nvim_create_autocmd({ "QuickFixCmdPost" }, {
    desc = "Automatically open location list window",
    group = QuickFixAG,
    pattern = "l*",
    command = "lwindow",
})
