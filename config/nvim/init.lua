vim.api.nvim_command("set runtimepath^=~/.vim runtimepath+=~/.vim/after")
vim.api.nvim_command("let &packpath = &runtimepath")

-- Reset path to default and add subdirectories to path
vim.api.nvim_command('set path& | let &path .= "**"')

-- Detect the type of a file automatically
-- and use the ftplugin and indent plugin for this ft
vim.api.nvim_command('filetype plugin indent on')
-- Enable syntax highlighting
vim.api.nvim_command('syntax on')

-- Custom settings in lua
require 'options'
require 'mappings'
require 'commands'
require 'abbreviations'
require 'statusline'
require 'autocommands'

require 'plugins'
-- Remainder of vimscript vimrc
-- vim.api.nvim_command("source ~/.vimrc")
require 'custom_colorscheme'
require 'diffsettings'
