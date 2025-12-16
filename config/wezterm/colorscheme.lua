-- Colorscheme Synchronization Between WezTerm and Neovim
--
-- This module manages the colorscheme state for WezTerm and coordinates with
-- Neovim to keep both applications synchronized. When toggle_colorscheme() is
-- called (via a keybinding setup in mappings.lya), both WezTerm and Neovim will
-- switch between light and dark modes.
--
-- The synchronization works by writing the current mode to /tmp/colorscheme,
-- which Neovim watches using a file watcher (see config/nvim/lua/colorscheme_watcher.lua).
--
-- See README.md for full documentation of this feature.

local wezterm = require 'wezterm'

local module = {}

local light_colorscheme = 'dayfox';
local dark_colorscheme = 'nightfox'

-- Shared state file: written by WezTerm, watched by Neovim
local colorscheme_file_path = '/tmp/colorscheme'

module.default_colorscheme_mode = "light" -- "light" or "dark"

function create_colorscheme_file()
    local file = io.open(colorscheme_file_path, "w")
    file:write(module.default_colorscheme_mode)
    file:close()
end

function read_colorscheme_file()
    local file = io.open(colorscheme_file_path, "r")
    content = file:read()
    file:close()
    return content
end

-- Read file from colorscheme_file_path
-- If the file doesn't exists or contains an invalid value
-- default to module.default_colorscheme_mode and set the file properly
--
-- Return the colorscheme to be used in wezterm init
function init_colorscheme()
    local success, content = pcall(read_colorscheme_file)

    if not success then
        wezterm.log_info('Could not read file content, using default')
        create_colorscheme_file()
        content = module.default_colorscheme_mode
    end

    if not (content == "light" or content == "dark") then
        wezterm.log_info('Invalid mode in file, using default', content)
        content = module.default_colorscheme_mode
    end

    if content == "light" then
        return light_colorscheme
    end

    return dark_colorscheme
end
module.init_colorscheme = init_colorscheme

-- When the file containing the theme changes reload the config
-- which triggers init_colorscheme() again.
-- This allows external scripts to modify the file and have
-- WezTerm updating automatically
wezterm.add_to_config_reload_watch_list(colorscheme_file_path)

-- Since the colorscheme_file_path is added to the config reload watch list
-- in init_colorscheme() this function will trigger a reload of the config
function module.toggle_colorscheme(window, pane, config)
    local success, content = pcall(read_colorscheme_file)

    local new_value = content == "light" and "dark" or "light"
    local file = io.open(colorscheme_file_path, "w")
    if file then
        file:write(new_value)
        file:close()
    end
end

return module
