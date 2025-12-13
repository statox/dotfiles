local wezterm = require 'wezterm'

local change_colorscheme = function(window, pane)
    -- This method is a helper to list the available colorscheme.
    -- When one is selected the function uses sed to update ~/.wezterm.lua
    -- to edit the line setting the colorscheme. With wezterm config autoreload
    -- feature this changes the colorscheme in the window immediately

    -- To use it add a mapping in the config like this:
    -- local change_colorscheme = require 'colorscheme_util'
    --
    -- {
    --  key = 'f',
    --  mods = 'LEADER',
    --  action = wezterm.action_callback(function(window, pane)
    --         window:toast_notification("wezterm", "Called <leader>f", nil, 4000)
    --         change_colorscheme(window, pane)
    --     end)
    -- },
    -- Wezterm debug overlay (ctrl+shift+l) can help debugging
    local act = wezterm.action
    -- get builting color schemes
    local schemes = wezterm.get_builtin_color_schemes()
    local choices = {}
    local config_path = "/home/adrien/.config/wezterm/wezterm.lua"

    -- populate theme names in choices list
    for key, _ in pairs(schemes) do
        table.insert(choices, { label = tostring(key) })
    end
    wezterm.log_info("in test()")

    -- sort choices list
    table.sort(choices, function(c1, c2)
        return c1.label < c2.label
    end)

    window:perform_action(
        act.InputSelector({
            title = "🎨 Pick a Theme!",
            choices = choices,
            fuzzy = true,

            -- execute 'sed' shell command to replace the line 
            -- responsible of colorscheme in my config
            action = wezterm.action_callback(function(inner_window, inner_pane, _, label)
                wezterm.log_info('in action callback')
                inner_window:perform_action(
                    act.SpawnCommandInNewTab({
                        args = {
                            "sed",
                            "-i",
                            -- '/^Colorscheme/c\\Colorscheme = "' .. label .. '"',
                            '/^config.color_scheme/c\\config.color_scheme = "' .. label .. '"',
                            config_path,
                        },
                    }),
                    inner_pane
                )
            end),
        }),
        pane
    )
end

return change_colorscheme
