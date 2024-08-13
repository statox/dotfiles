local command = vim.api.nvim_create_user_command

-- :H Open help vertically with H
command("H", "call help#VerticalHelp(<f-args>)", { complete = "help", nargs = 1, force = true })

-- :W save file with sudo permissions
command("W", "w !sudo tee % > /dev/null", { force = true })

-- :E equivalent to :e%
command("E", "call utils#ReloadOrEdit(<q-args>)", { nargs = "?", complete = "file", force = true })

-- :GGUK Shortcut for a plugin command undoing the current git hunk
command("GGUH", "SignifyHunkUndo", { force = true })
command("GGDH", "SignifyHunkDiff", { force = true })

-- Show buffer commit history
command("Gbcommits", "Telescope git_bcommits", { force = true })

-- Show LSP diagnostics with Telescope
command("Diag", "Telescope diagnostics", { force = true })

-- :GFS Show git modified files
command("GFS", "Neotree toggle show git_status left", { force = true })

-- Disambiguate fugitive commands {{{
command("Gblame", "Git blame", { force = true })
command("Gco", 'execute input("Checkout current file? [yY] ") ==? "y" ? "Git checkout %" : ""', { force = true })
-- }}}
