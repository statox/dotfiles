-- Rename TMUX tab vim name of edited file {{{
vim.api.nvim_exec([[
    augroup tmux
        autocmd!
        autocmd BufReadPost,FileReadPost,BufNewFile,BufEnter * call system("tmux rename-window '" . expand("%:t") . "'")
        autocmd VimLeave * call system('tmux set-window automatic-rename on')
    augroup END
]], false)

-- Highlight text on yank
vim.api.nvim_exec([[
    augroup YankHighlight
        autocmd!
        autocmd TextYankPost * silent! lua vim.highlight.on_yank {higroup="IncSearch", timeout=150}
    augroup END
]], false)

vim.api.nvim_exec([[
    augroup Neoformat
        autocmd!
        autocmd BufWritePre *.js Neoformat
        autocmd BufWritePre *.ts Neoformat
    augroup END
]], false)
