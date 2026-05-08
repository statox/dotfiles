vim.opt_local.textwidth = 0
vim.opt_local.wrap = true

-- Diagnostics (e.g. Harper grammar) are disabled by default in markdown.
-- Use :ToggleDiagnostics to enable/disable them.
local bufnr = vim.api.nvim_get_current_buf()
vim.diagnostic.enable(false, { bufnr = bufnr })

vim.api.nvim_buf_create_user_command(bufnr, "MarkdownDiagnosticsToggle", function()
    local enabled = vim.diagnostic.is_enabled({ bufnr = bufnr })
    vim.diagnostic.enable(not enabled, { bufnr = bufnr })
    vim.notify("Diagnostics " .. (not enabled and "enabled" or "disabled"), vim.log.levels.INFO)
end, { desc = "Toggle diagnostics for this buffer" })
