require("Comment").setup({
    ---Add a space b/w comment and the line
    padding = true,
    ---Whether the cursor should stay at its position
    sticky = true,
    ---Lines to be ignored while (un)comment
    ignore = "^$",
    -- Test using the default mappings
    -- TODO remove bad habit config in mappings.lua when removing these lines
    -- ---LHS of toggle mappings in NORMAL mode
    -- toggler = {
    --     ---Line-comment toggle keymap
    --     line = "<leader>c<space>",
    --     ---Block-comment toggle keymap
    --     block = "<leader>cs<space>",
    -- },
    -- ---LHS of operator-pending mappings in NORMAL and VISUAL mode
    -- opleader = {
    --     ---Line-comment keymap
    --     line = "<leader>c",
    --     ---Block-comment keymap
    --     block = "<leader>cs",
    -- },
    ---LHS of extra mappings
    -- extra = {
    --     ---Add comment on the line above
    --     above = "gcO",
    --     ---Add comment on the line below
    --     below = "gco",
    --     ---Add comment at the end of line
    --     eol = "gcA",
    -- },
    ---Enable keybindings
    ---NOTE: If given `false` then the plugin won't create any mappings
    mappings = {
        ---Operator-pending mapping; `gcc` `gbc` `gc[count]{motion}` `gb[count]{motion}`
        basic = true,
        ---Extra mapping; `gco`, `gcO`, `gcA`
        extra = true,
        ---Extended mapping; `g>` `g<` `g>[count]{motion}` `g<[count]{motion}`
        extended = false,
    },
    ---Function to call before (un)comment
    -- TODO: See if I can hack nerdcommenter's "sexy comment" here
    pre_hook = nil,
    ---Function to call after (un)comment
    post_hook = nil,
})

local api = require('Comment.api')
local config = require('Comment.config')

-- Use gcy/gcyy to yank then comment {{{
-- Maybe consider leaving a comment here once I'll have tested the solution long enough
-- https://github.com/numToStr/Comment.nvim/issues/468

-- Operatorfunc callback for gcy{motion}
function _G._yank_and_comment(motion)
    -- Save '[ and '] marks (g@ sets them, but yank overwrites them)
    local s = vim.api.nvim_buf_get_mark(0, '[')
    local e = vim.api.nvim_buf_get_mark(0, ']')

    -- Yank the region linewise
    vim.cmd.normal({ args = { "'[V']y" }, bang = true })

    -- Restore marks so Comment.nvim reads the correct region
    vim.api.nvim_buf_set_mark(0, '[', s[1], s[2], {})
    vim.api.nvim_buf_set_mark(0, ']', e[1], e[2], {})

    api.locked('toggle.linewise')(motion)
end

-- Operatorfunc callback for gcyy (current line)
function _G._yank_and_comment_current(_motion)
    vim.cmd.normal({ args = { 'yy' }, bang = true })
    api.locked('toggle.linewise.current')()
end

-- gcy{motion}: operator-pending (e.g. gcyip, gcyab, gcy3j)
vim.keymap.set('n', 'gcy', function()
    vim.o.operatorfunc = "v:lua._yank_and_comment"
    config.position = config:get().sticky and vim.api.nvim_win_get_cursor(0) or nil
    return 'g@'
end, { expr = true, desc = 'Yank and comment (operator)' })

-- gcyy: current line (dot-repeatable via g@$)
vim.keymap.set('n', 'gcyy', function()
    vim.o.operatorfunc = "v:lua._yank_and_comment_current"
    config.position = config:get().sticky and vim.api.nvim_win_get_cursor(0) or nil
    return 'g@$'
end, { expr = true, desc = 'Yank and comment current line' })

-- Visual gcy: yank selection then comment
vim.keymap.set('x', 'gcy', function()
    vim.cmd.normal({ args = { 'Y' }, bang = true })
    api.locked('toggle.linewise')(vim.fn.visualmode())
end, { desc = 'Yank and comment selection' })
-- }}}
