-- Pull in the wezterm API
local wezterm = require 'wezterm'
local colorscheme = require 'colorscheme'
local ui = require 'ui'
local mappings = require 'mappings'

local config = wezterm.config_builder()

-- Show a notification when the config reloads
wezterm.on("window-config-reloaded", function(window, pane)
  window:toast_notification("wezterm", "Config reloaded!", nil, 1000)
end)

ui.setup_ui(config)
mappings.setup_bindings(config)

-- Finally, return the configuration to wezterm:
return config
