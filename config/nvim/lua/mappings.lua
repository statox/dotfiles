-- vim:fdm=marker

-- Helper functions {{{
local function nnoremap(lhs, rhs)
    vim.keymap.set('n', lhs, rhs, { noremap = true })
end

local function xnoremap(lhs, rhs)
    vim.keymap.set('x', lhs, rhs, { noremap = true })
end

local function cnoremap(lhs, rhs)
    vim.keymap.set('c', lhs, rhs, { noremap = true })
end

local function inoremap(lhs, rhs)
    vim.keymap.set('x', lhs, rhs, { noremap = true })
end

-- }}}

-- <C-L> turn off search highlighting until the next search {{{
nnoremap('<C-L>', ':nohlsearch<CR><C-L>')
-- }}}
-- Fast quit {{{
nnoremap('<Leader><S-Q>', ':qa!<CR>')
nnoremap('<Leader><S-A>', ':%bdelete<CR>')
nnoremap('<Leader><S-S>', ':%bdelete<CR><C-o>') -- Go back to previous buffer once all others are closed
-- }}}
-- Easier clipboard access {{{
xnoremap('<Leader>y', '"+y')

xnoremap('<Leader>p', '"+p')
nnoremap('<Leader>p', '"+p')

xnoremap('<Leader><S-p>', '"+P')
nnoremap('<Leader><S-p>', '"+P')
-- }}}
-- Quickly escape insert mode with jk {{{
vim.keymap.set('i', 'jk', '<Esc>:update<CR>', { noremap = true, silent = true })
vim.keymap.set('n', '<Leader>jk', '<Esc>:update<CR>', { noremap = true, silent = true })
-- }}}
-- Quickly insert an empty new line without entering insert mode {{{
nnoremap('<Leader>o', 'o<Esc>0"_D')
nnoremap('<Leader>O', 'O<Esc>0"_D')
-- }}}
-- Use T in visual mode to start Tabular function {{{
vim.keymap.set('x', 'T', ':Tabular / ', { noremap = true })
-- }}}
-- Use gp to select last pasted text {{{
nnoremap('gp', "'[v']")
-- }}}
-- Delete the current word in insert mode with <C-backspace> {{{
inoremap(' ', '<C-w>')
-- }}}
-- Make command line navigation easier {{{
cnoremap('<C-l>', '<Right>')
cnoremap('<C-h>', '<Left>')
cnoremap('<C-k>', '<S-Up>')
cnoremap('<C-j>', '<S-Down>')
-- }}}
-- Diff mode mapping {{{
-- Use <C-J> and <C-K> for ]c and [c in diff mode
vim.keymap.set('n', '<C-J>', "&diff ? ']c' : '<C-J>'", { noremap = true, silent = true, expr = true })
vim.keymap.set('n', '<C-K>', "&diff ? '[c' : '<C-K>'", { noremap = true, silent = true, expr = true })
-- }}}
-- Use ]g and [g to navigate through git hunk thanks to a plugin {{{
vim.keymap.set('n', ']g', '<plug>(signify-next-hunk)')
vim.keymap.set('n', '[g', '<plug>(signify-prev-hunk)')
-- }}}
-- Center next match with <leader>n {{{
nnoremap('<leader>n', 'nzz')
nnoremap('<leader>N', 'Nzz')
-- }}}
-- Make * and # dont navigate to the next occurence {{{
nnoremap('*', '*N')
nnoremap('#', '#N')
-- }}}
-- Telescope mappings {{{
nnoremap('ga', "<cmd>lua require('telescope.builtin').live_grep()<cr>")
xnoremap('ga', "y<cmd>lua require('telescope.builtin').grep_string({word_match = '-w', search = vim.fn.getreg('\"')})<CR>")
-- }}}
-- make h and l skip indentation white spaces {{{
vim.keymap.set('n', 'h', ':call motion#SkipOrH()<CR>', { noremap = true, silent = true })
vim.keymap.set('n', 'l', ':call motion#SkipOrL()<CR>', { noremap = true, silent = true })
-- }}}
-- Explore with - {{{
nnoremap('-', ':Neotree toggle focus filesystem %:p<cr>')
-- }}}
-- Disable Q to toggle ex mode {{{
nnoremap('Q', '<nop>')
-- }}}
-- vim-subversive mappings {{{
-- Use gc as a word to replace a text object with the content of the unmaned register
vim.keymap.set('n', 'gc', '<plug>(SubversiveSubstitute)')
vim.keymap.set('n', 'gcc', '<plug>(SubversiveSubstituteLine)')
-- }}}
-- Switch j and k with gj and gk respectively to improve wrapped lines navigation {{{
nnoremap('j', 'gj')
nnoremap('k', 'gk')
nnoremap('gj', 'j')
nnoremap('gk', 'k')
-- }}}
-- Get back the original Y mapping in neovim {{{
nnoremap('Y', 'yy')
-- }}}
-- Make <Esc> work in terminal mode {{{
vim.keymap.set('t', '<Esc>', "<C-\\><C-n>")
-- }}}
-- Search for selected text, forwards or backwards {{{
vim.api.nvim_exec([[
xnoremap <silent> # :<C-U>
  \let saveReg=[getreg('"'), getregtype('"')]<CR>
  \gvy?<C-R><C-R>=substitute(escape(@", '?\.*$^~['), '\_s\+', '\\_s\\+', 'g')<CR><CR>
  \gV:call setreg('"', saveReg[0], saveReg[1])<CR>N

xnoremap <silent> * :<C-U>
  \let saveReg=[getreg('"'), getregtype('"')]<CR>
  \gvy/<C-R><C-R>=substitute(escape(@", '/\.*$^~['), '\_s\+', '\\_s\\+', 'g')<CR><CR>
  \gV:call setreg('"', saveReg[0], saveReg[1])<CR>N
]], false)
-- }}}
-- Buffer mappings {{{
nnoremap('<Leader><CR>', '<cmd>Telescope find_files<cr>')
nnoremap('<Leader>l', ':bnext<CR>')
nnoremap('<Leader>h', ':bNext<CR>')
nnoremap('<Leader>bd', ':bdelete<CR>')
nnoremap('<Leader><Leader>b', ':enew<CR>')
-- Show buffer list with Neotree
nnoremap('<Leader>bb', ':Neotree toggle show buffers right<cr>')
-- show buffer list and allow to type the buffer name to use with <Leader>bb
nnoremap('gb', ':ls<CR>:b<space>')
-- }}}
-- Manage tabs {{{
-- open/close tab
nnoremap('<Leader><Leader>t', ':tabnew<CR>')
nnoremap('<Leader>tc', ':tabclose<CR>')
-- open a new tab with the current file
nnoremap('<Leader>t%', ":execute 'tabnew +' . line('.') . ' %'<CR>zz")
-- move current tab to left/right
nnoremap('<Leader><Leader><Left>', ':tabmove -1<CR>')
nnoremap('<Leader><Leader><Right>', ':tabmove +1<CR>')

-- Easily access tabs by index in normal mode with g[number]
for tabIndex = 1, 8 do
    --execute 'nnoremap g' . tabIndex . ' ' . tabIndex . 'gt'
    nnoremap('g' .. tabIndex, tabIndex .. 'gt')
end
-- Access the last tab with g9
nnoremap('g9', ':tablast<CR>')
--}}}
