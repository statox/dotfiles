-- TODO Factorize in a mapping module
local function inoremap(lhs, rhs)
    vim.keymap.set("i", lhs, rhs, { noremap = true, buffer = true })
end
local function nnoremap(lhs, rhs)
    vim.keymap.set("n", lhs, rhs, { noremap = true, buffer = true })
end

inoremap("p===", "print('=========================================================');")
inoremap("p###", "print('#########################################################');")
inoremap("p---", "print('---------------------------------------------------------');")
inoremap("p***", "print('*********************************************************');")
inoremap("p^^^", "print('^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^');")
inoremap("pvvv", "print('vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv');")

-- Override the default python ft plugin which uses a custom function I don't like
-- This should probably be handled by setting g:no_python_maps in my config
nnoremap("]]", ':AerialNext<CR>')
nnoremap("[[", ':AerialPrev<CR>')
