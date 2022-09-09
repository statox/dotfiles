local wilder = require('wilder')

vim.api.nvim_command('set wildchar=<C-n>')

wilder.setup({
    modes = {':', '/', '?'}
})
