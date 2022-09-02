vim.api.nvim_command("echom 'Loading init.lua'")
vim.api.nvim_command("set runtimepath^=~/.vim runtimepath+=~/.vim/after")
vim.api.nvim_command("let &packpath = &runtimepath")

-- Custom settings in lua
require 'options'

-- Remainder of vimscript vimrc
vim.api.nvim_command("source ~/.vimrc")
