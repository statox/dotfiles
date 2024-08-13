-- Used in web ftplugin

local commonWebSettings = {}

-- TODO Factorize in a mapping module
local function inoremap(lhs, rhs)
    vim.keymap.set("i", lhs, rhs, { noremap = true, buffer = true })
end

function commonWebSettings.createMappings()
    inoremap("debug", "debugger; // AFA")
    inoremap("cerr", "console.error();<Left><Left>")
    inoremap("clog", "console.log();<Left><Left>")
    inoremap("c===", "console.log('=========================================================');")
    inoremap("c###", "console.log('#########################################################');")
    inoremap("c---", "console.log('---------------------------------------------------------');")
    inoremap("c***", "console.log('*********************************************************');")
    inoremap("c^^^", "console.log('^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^');")
    inoremap("cvvv", "console.log('vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv');")
end

return commonWebSettings
