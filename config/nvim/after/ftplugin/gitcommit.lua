-- start in insert mode at the beginning of the file
vim.api.nvim_create_autocmd({ "BufEnter" }, {
    desc = "Start in insert mode at the beginning of the commit interface",
    group = vim.api.nvim_create_augroup("insertModeInGitCommit", { clear = true }),
    callback = function(event)
        if vim.o.modifiable == false then
            return
        end

        vim.api.nvim_command("normal! gg0")
        vim.api.nvim_command("startinsert")
    end,
})

-- Change the color of columns 60 and 70 before the end of line
vim.opt.colorcolumn = "60,70"
