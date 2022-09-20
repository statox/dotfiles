-- Diff configurations

-- Show file lines, ignore whitespaces in diff
vim.opt.diffopt = 'filler,iwhite'


-- Use custom command to create the diff
vim.opt.diffexpr = 'diff#DiffW()'

local command = vim.api.nvim_create_user_command

command('DT', 'execute "colorscheme " . g:colorsDiff | windo diffthis', { force = true })
command('DO', 'execute "colorscheme " . g:colorsDefault | windo diffoff', { force = true })
command('DG', 'diffget ', { force = true })
command('DP', 'diffput ', { force = true })
