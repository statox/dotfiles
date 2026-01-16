-- The plugin adds indent guide vertical lines
require("ibl").setup({
    indent = { char = "│" },
    -- scope displays the indentation level where variables
    -- or functions are accessible
    scope = { enabled = true },
})
