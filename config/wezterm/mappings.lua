
local wezterm = require 'wezterm'
local colorscheme = require 'colorscheme'
local module = {}

function module.setup_bindings(config)
    config.leader = { key = ' ', mods = 'CTRL', timeout_milliseconds = 1000 }

    config.key_tables = {
        -- Defines the keys that are active in our resize-pane mode.
        -- Since we're likely to want to make multiple adjustments,
        -- we made the activation one_shot=false. We therefore need
        -- to define a key assignment for getting out of this mode.
        -- 'resize_pane' here corresponds to the name="resize_pane" in
        -- the key assignments above.
        resize_pane = {
            { key = 'LeftArrow', action = wezterm.action.AdjustPaneSize { 'Left', 1 } },
            { key = 'RightArrow', action = wezterm.action.AdjustPaneSize { 'Right', 1 } },
            { key = 'UpArrow', action = wezterm.action.AdjustPaneSize { 'Up', 1 } },
            { key = 'DownArrow', action = wezterm.action.AdjustPaneSize { 'Down', 1 } },

            -- Cancel the mode by pressing escape
            { key = 'Escape', action = 'PopKeyTable' },
        },
    }

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

        -- Resize panes with <leader>+Left,Up,RightDown
        -- { key = 'r', mods = 'LEADER', action = act.ActivateKeyTable { name = 'resize_pane', one_shot = false } },
        { key = 'LeftArrow', mods = 'LEADER', action = wezterm.action.ActivateKeyTable { name = 'resize_pane', one_shot = false } },
        { key = 'DownArrow', mods = 'LEADER', action = wezterm.action.ActivateKeyTable { name = 'resize_pane', one_shot = false } },
        { key = 'UpArrow', mods = 'LEADER', action = wezterm.action.ActivateKeyTable { name = 'resize_pane', one_shot = false } },
        { key = 'RightArrow', mods = 'LEADER', action = wezterm.action.ActivateKeyTable { name = 'resize_pane', one_shot = false } },

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
        -- paste from the clipboard
        { key = 'p', mods = 'LEADER', action = wezterm.action.PasteFrom('Clipboard') },

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
