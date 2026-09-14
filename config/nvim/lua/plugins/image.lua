-- 3rd/image.nvim: Render images (including in markdown buffers) inside the editor
-- Requires a supported backend terminal (we use wezterm) plus ImageMagick on the
-- system for the magick_cli processor.

require("image").setup({
    backend = "sixel",
    processor = "magick_cli",
    integrations = {
        markdown = {
            enabled = true,
            clear_in_insert_mode = false,
            download_remote_images = false,
            only_render_image_at_cursor = false,
            filetypes = { "markdown" },
        },
        neorg = { enabled = false },
        typst = { enabled = false },
        html = { enabled = false },
        css = { enabled = false },
    },
    max_height_window_percentage = 10,
    scale_factor = 1.0,
    window_overlap_clear_enabled = false,
    editor_only_render_when_focused = false,
    tmux_show_only_in_active_window = false,
})

-- Commands to toggle image rendering on the fly
local image = require("image")

vim.api.nvim_create_user_command("ImageEnable", function()
    image.enable()
end, { desc = "Enable image.nvim rendering" })

vim.api.nvim_create_user_command("ImageDisable", function()
    image.disable()
end, { desc = "Disable image.nvim rendering" })

vim.api.nvim_create_user_command("ImageToggle", function()
    if image.is_enabled() then
        image.disable()
    else
        image.enable()
    end
end, { desc = "Toggle image.nvim rendering" })
