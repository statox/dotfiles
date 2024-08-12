-- Try to format on save
vim.api.nvim_exec([[
    augroup Neoformat
        autocmd!
        autocmd BufWritePre *.js Neoformat
        autocmd BufWritePre *.ts Neoformat
        autocmd BufWritePre *.tsx Neoformat
    augroup END
]], false)

-- Try to find the binary of the formater in a node_modules/.bin
-- useful for eslint and prettier
-- IMPORTANT: I had to `npm i -g eslint_d` to get all formating working properly (prettier is fine as local install)
vim.g.neoformat_try_node_exe = 1

-- Run all enabled formatters (by default stops after the first formatter succeeds)
vim.g.neoformat_run_all_formatters = 1
