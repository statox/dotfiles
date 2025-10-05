local module = {}

local light_colorscheme = 'dayfox';
local dark_colorscheme = 'nightfox'

module.default_colorscheme = dark_colorscheme

function module.toggle_colorscheme(window, pane)
    -- We can't read an environment variable set by zshrc to read the the
    -- so instead we create a mapping to switch manually. To be improved.
    if not window:get_config_overrides() then
        window:set_config_overrides {
            color_scheme = light_colorscheme,
        }
        return
    end

    if window:get_config_overrides().color_scheme == light_colorscheme then
        window:set_config_overrides {
            color_scheme = dark_colorscheme,
        }
    else
        window:set_config_overrides {
            color_scheme = light_colorscheme,
        }
    end
end

return module
