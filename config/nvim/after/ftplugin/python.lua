-- TODO Factorize in a mapping module
local function inoremap(lhs, rhs)
    vim.keymap.set("i", lhs, rhs, { noremap = true, buffer = true })
end

inoremap("p===", "print('=========================================================');")
inoremap("p###", "print('#########################################################');")
inoremap("p---", "print('---------------------------------------------------------');")
inoremap("p***", "print('*********************************************************');")
inoremap("p^^^", "print('^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^');")
inoremap("pvvv", "print('vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv');")
