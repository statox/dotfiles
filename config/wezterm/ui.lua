local wezterm = require 'wezterm'
local colorscheme = require 'colorscheme'


function basename(s)
    return string.gsub(s, '(.*[/\\])(.*)', '%2')
end

function tab_title(tab_info)
    local pane = tab_info.active_pane
    local cwd = pane.current_working_dir
    local cwd_string = tostring(cwd)
    local title = basename(cwd_string)

    return title
end

wezterm.on('format-tab-title', function(tab, tabs, panes, config, hover, max_width)
    local default_background = '#333333'
    local edge_background = '#333333'
    local background = default_background
    local foreground = '#a0a0a0' -- default inactive color
    local zoomed = false

    -- Check if this tab has a zoomed pane
    for _, pane in ipairs(tab.panes) do
        if pane.is_zoomed then
            zoomed = true
            break
        end
    end

    -- Change foreground color for active tab and zoomed state
    if tab.is_active then
        if zoomed then
            foreground = '#00afff' -- blue if zoomed
        else
            foreground = '#ffffff' -- white if active but not zoomed
            background = "#3a4460"
        end
    end

    local title = tab_title(tab)
    return {
        { Background = { Color = background } },
        { Foreground = { Color = foreground } },
        { Text = ' ' .. title .. ' ' },
        { Background = { Color = default_background } },
        { Text = '|' },
    }
end)

local module = {}

function module.setup_ui(config)
    -- Changing the font size and color scheme.
    config.font_size = 11
    config.color_scheme = colorscheme.default_colorscheme

    -- tab bar
    config.window_frame = {
        -- The font used in the tab bar.
        -- Roboto Bold is the default; this font is bundled
        -- with wezterm.
        -- Whatever font is selected here, it will have the
        -- main font setting appended to it to pick up any
        -- fallback fonts you may have used there.
        -- font = wezterm.font { family = 'Roboto', weight = 'Bold' },
        -- font = wezterm.font { family = 'AurulentSansMono Nerd Font', weight = 'Bold' },

        -- The size of the font in the tab bar.
        -- Default to 10.0 on Windows but 12.0 on other systems
        font_size = 11.0,

        -- The overall background color of the tab bar when
        -- the window is focused
        active_titlebar_bg = '#333333',

        -- The overall background color of the tab bar when
        -- the window is not focused
        inactive_titlebar_bg = '#333333',
    }

    config.tab_bar_at_bottom = false
    config.use_fancy_tab_bar = false

    -- Window padding
    config.window_padding = {
        left = 0,
        right = 0,
        top = 0,
        bottom = 0,
    }
end

return module
