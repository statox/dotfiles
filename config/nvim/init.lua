-- Reset path to default and add subdirectories to path
-- TODO 09/09/2025 Disabling because I don't think I need that anymore. Let's keep it here long enough to validate the assumption.
-- vim.api.nvim_command('set path& | let &path .= "**"')

-- Custom settings in lua
require("options")
require("mappings")
require("commands")
require("abbreviations")
require("statusline")
require("autocommands")

require("plugins")
-- Remainder of vimscript vimrc
-- vim.api.nvim_command("source ~/.vimrc")
require("colorscheme_custom")
require("colorscheme_watcher")
require("diffsettings")
