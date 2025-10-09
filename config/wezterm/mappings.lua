
local wezterm = require 'wezterm'
local colorscheme = require 'colorscheme'
local module = {}

function module.setup_bindings(config)
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
                colorscheme.toggle_colorscheme(window, pane)
            end)
        },
    }
end

return module
