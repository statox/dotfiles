if vim.fn.has("termguicolors") then
    vim.opt.termguicolors = true
end

if os.getenv("LIGHT_THEME") == "1" then
    vim.g.colorsDefault = "dayfox"
    vim.g.colorsDiff = "dayfox"
else
    vim.g.colorsDefault = "nightfox"
    vim.g.colorsDiff = "nordfox"
end

vim.cmd("colorscheme " .. vim.g.colorsDefault)

-- I want the font of the current tab in the tabline line to be
-- mode visible than what the colorscheme does.
-- So I update the group TabLineSel which is used to define the
-- style of the current tab in the tabline.
--
-- Because nvim_set_hl() updates the whole highlighting group I
-- need to get the original properties of the group and merge
-- them with the changes
--
local function preserve_and_bold_tablinesel()
    local keyword_id = vim.fn.hlID("Keyword")
    local id = vim.fn.hlID("TabLineSel")

    if id == 0 or keyword_id == 0 then
        -- group doesn't exist yet; apply bold anyway (will be fixed after ColorScheme)
        vim.api.nvim_set_hl(0, "TabLineSel", { bold = true })
        return
    end

    -- We get the foreground color from the group
    local transKeyword = vim.fn.synIDtrans(keyword_id)
    local fg = vim.fn.synIDattr(transKeyword, "guifg#")

    -- And the other properties from the original TabLineSel
    local trans = vim.fn.synIDtrans(id)
    local bg = vim.fn.synIDattr(trans, "bg#")
    local sp = vim.fn.synIDattr(trans, "sp#")

    local opts = { bold = true }
    if fg ~= "" then opts.fg = fg end
    if bg ~= "" then opts.bg = bg end
    if sp ~= "" then opts.sp = sp end

    vim.api.nvim_set_hl(0, "TabLineSel", opts)
end

-- apply now
preserve_and_bold_tablinesel()

-- and re-apply after every colorscheme change
vim.api.nvim_create_autocmd("ColorScheme", {
    callback = preserve_and_bold_tablinesel,
})
