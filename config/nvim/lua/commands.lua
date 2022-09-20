local command = vim.api.nvim_create_user_command

-- :H Open help vertically with H
command('H', 'call help#VerticalHelp(<f-args>)', { complete = 'help', nargs = 1, force = true })

-- :W save file with sudo permissions
command('W', 'w !sudo tee % > /dev/null', { force = true })

-- :E equivalent to :e%
command('E', 'call utils#ReloadOrEdit(<q-args>)', { nargs = '?', complete = 'file', force = true })

-- :GGUK Shortcut for a plugin command undoing the current git hunk
command('GGUH', 'SignifyHunkUndo', { force = true })
command('GGDH', 'SignifyHunkDiff', { force = true })

-- :GFS Show git modified files
command('GFS', 'Neotree toggle show git_status left', { force = true })

-- Disambiguate fugitive commands {{{
command('Gblame', 'Git blame', { force = true })
command('Gl', 'Git pull', { force = true })
command('Gp', 'Git push', { force = true })
command('Gc', 'Git commit', { force = true })
command('Gs', 'Git status', { force = true })
-- }}}
