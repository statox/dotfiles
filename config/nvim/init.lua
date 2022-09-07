vim.api.nvim_command("echom 'Loading init.lua'")
vim.api.nvim_command("set runtimepath^=~/.vim runtimepath+=~/.vim/after")
vim.api.nvim_command("let &packpath = &runtimepath")

-- Custom settings in lua
require 'options'
require 'mappings'
require 'commands'

-- Remainder of vimscript vimrc
vim.api.nvim_command("source ~/.vimrc")
require 'custom_colorscheme'
