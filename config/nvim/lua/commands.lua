local command = vim.api.nvim_create_user_command

-- :H Open help vertically with H
command("H", function(opts)
    vim.cmd("vertical botright help " .. opts.args)
    vim.cmd("vertical resize 78")
end, { complete = "help", nargs = 1, force = true })

-- :W save file with sudo permissions
command("W", "w !sudo tee % > /dev/null", { force = true })

-- :E equivalent to :e%
command("E", function(opts)
    if opts.args == "" then
        vim.cmd("e %")
    else
        vim.cmd("e " .. opts.args)
    end
end, { nargs = "?", complete = "file", force = true })

-- :GGUK Shortcut for a plugin command undoing the current git hunk
command("GGUH", "SignifyHunkUndo", { force = true })
command("GGDH", "SignifyHunkDiff", { force = true })

-- Show buffer commit history
command("Gbcommits", "Telescope git_bcommits", { force = true })

-- Show LSP diagnostics with Telescope
command("Diag", "Telescope diagnostics", { force = true })

-- :GFS Show git modified files
command("GFS", "Neotree action=focus source=git_status position=left", { force = true })

-- Disambiguate fugitive commands {{{
command("Gblame", "Git blame", { force = true })
command("Gco", 'execute input("Checkout current file? [yY] ") ==? "y" ? "Git checkout %" : ""', { force = true })
-- }}}
