-- Pull in the wezterm API
local wezterm = require 'wezterm'

local toggle_colorscheme = function(window, pane)
    -- We can't read an environment variable set by zshrc to read the the
    -- so instead we create a mapping to switch manually. To be improved.
    if not window:get_config_overrides() then
        local scheme = "dayfox"
        window:set_config_overrides {
            color_scheme = scheme,
        }
        return
    end

    if window:get_config_overrides().color_scheme == "dayfox" then
        local scheme = "nightfox"
        window:set_config_overrides {
            color_scheme = scheme,
        }
        return
    else
        local scheme = "dayfox"
        window:set_config_overrides {
            color_scheme = scheme,
        }
        return
    end
end

local config = wezterm.config_builder()

-- Changing the font size and color scheme.
config.font_size = 11
config.color_scheme = "nightfox"


config.leader = { key = ' ', mods = 'CTRL', timeout_milliseconds = 1000 }
config.keys = {
    -- Activates the Command Palette, a modal overlay that enables discovery and activation of various commands.
    { key = 'P', mods = 'CTRL', action = wezterm.action.ActivateCommandPalette, },

    -- Split current window
    { key = '!', mods = 'LEADER|SHIFT', action = wezterm.action.SplitHorizontal({ domain = 'CurrentPaneDomain' }), },
    { key = '/', mods = 'LEADER', action = wezterm.action.SplitVertical ( { domain = 'CurrentPaneDomain' } ), },

    -- Move focus between panes
    { key = 'h', mods = 'LEADER', action = wezterm.action.ActivatePaneDirection('Left') },
    { key = 'j', mods = 'LEADER', action = wezterm.action.ActivatePaneDirection('Down') },
    { key = 'k', mods = 'LEADER', action = wezterm.action.ActivatePaneDirection('Up')   },
    { key = 'l', mods = 'LEADER', action = wezterm.action.ActivatePaneDirection('Right')},

    -- Resize panes with <leader>+CTRL+h/j/k/l
    { key = 'LeftArrow', mods = 'LEADER', action = wezterm.action.AdjustPaneSize { 'Left', 3 } },
    { key = 'DownArrow', mods = 'LEADER', action = wezterm.action.AdjustPaneSize { 'Down', 3 } },
    { key = 'UpArrow', mods = 'LEADER', action = wezterm.action.AdjustPaneSize { 'Up', 3 } },
    { key = 'RightArrow', mods = 'LEADER', action = wezterm.action.AdjustPaneSize { 'Right', 3 } },

    -- Close pane
    { key = 'x', mods = 'LEADER', action = wezterm.action.CloseCurrentPane { confirm = true }, },

    -- Switch to the previous/next pane (} is useless but kept until I break the habit)
    { key = '{', mods = 'LEADER|SHIFT', action = wezterm.action.PaneSelect { mode = "SwapWithActiveKeepFocus" } },
    { key = '}', mods = 'LEADER|SHIFT', action = wezterm.action.PaneSelect { mode = "SwapWithActiveKeepFocus" } },

    -- Toogle pane zoom state
    { key = 'z', mods = 'LEADER', action = wezterm.action.TogglePaneZoomState, },

    -- Switch to the previous/next tab
    { key = 'h', mods = 'LEADER|CTRL', action = wezterm.action.ActivateTabRelative(-1) },
    { key = 'l', mods = 'LEADER|CTRL', action = wezterm.action.ActivateTabRelative(1) },

    { key = 'LeftArrow', mods = 'LEADER|CTRL', action = wezterm.action.MoveTabRelative(-1) },
    { key = 'RightArrow', mods = 'LEADER|CTRL', action = wezterm.action.MoveTabRelative(1) },

    -- New tab
    { key = 'c', mods = 'LEADER', action = wezterm.action.SpawnTab("DefaultDomain") },

    -- Enter copy mode
    { key = 'Escape', mods = 'LEADER', action = wezterm.action.ActivateCopyMode },

    -- Toggle light and dark colorscheme
    {
     key = 'f',
     mods = 'LEADER',
     action = wezterm.action_callback(function(window, pane)
            toggle_colorscheme(window, pane)
        end)
    },
}

-- Show a notification when the config reloads
wezterm.on("window-config-reloaded", function(window, pane)
  window:toast_notification("wezterm", "Config reloaded!", nil, 4000)
end)

-- tab bar
config.window_frame = {
    -- The font used in the tab bar.
    -- Roboto Bold is the default; this font is bundled
    -- with wezterm.
    -- Whatever font is selected here, it will have the
    -- main font setting appended to it to pick up any
    -- fallback fonts you may have used there.
    font = wezterm.font { family = 'Roboto', weight = 'Bold' },

    -- The size of the font in the tab bar.
    -- Default to 10.0 on Windows but 12.0 on other systems
    font_size = 12.0,

    -- The overall background color of the tab bar when
    -- the window is focused
    active_titlebar_bg = '#333333',

    -- The overall background color of the tab bar when
    -- the window is not focused
    inactive_titlebar_bg = '#333333',
}

config.tab_bar_at_bottom = true


-- Window padding
config.window_padding = {
  left = 0,
  right = 0,
  top = 0,
  bottom = 0,
}

-- Finally, return the configuration to wezterm:
return config
