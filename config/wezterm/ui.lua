local wezterm = require 'wezterm'
local colorscheme = require 'colorscheme'

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
        font = wezterm.font { family = 'Roboto', weight = 'Bold' },

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

    config.tab_bar_at_bottom = true
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
