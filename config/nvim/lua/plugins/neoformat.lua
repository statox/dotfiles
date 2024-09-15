-- See comments in lsp.lua: The formatter used by this plugin
-- can't be automatically installed by Mason.nvim so we install
-- them manually.

-- Try to format on save
local neoformatAG = vim.api.nvim_create_augroup("Neoformat", { clear = true })
vim.api.nvim_create_autocmd({ "BufWritePre" }, {
    desc = "Automatically format buffer on save with Neoformat plugin",
    -- pattern = { "*.js", "*.ts", "*.tsx", "*.lua", "*.ino", "*.cpp", "*.h" },
    pattern = { "*" },
    group = neoformatAG,
    command = "Neoformat",
})

vim.api.nvim_create_user_command("NeoformatToggleVerbose", function()
    if vim.g.neoformat_verbose == 1 then
        vim.g.neoformat_verbose = 0
    else
        vim.g.neoformat_verbose = 1
    end
end, {})

-- Try to find the binary of the formater in a node_modules/.bin
-- useful for eslint and prettier
-- IMPORTANT: I had to `npm i -g eslint_d` to get all formating working properly (prettier is fine installed locally in the projects)
vim.g.neoformat_try_node_exe = 1

-- Run all enabled formatters (by default stops after the first formatter succeeds)
vim.g.neoformat_run_all_formatters = 1

vim.g.neoformat_enabled_typescript = { "eslint_d", "prettierd" }
vim.g.neoformat_enabled_typescriptreact = { "eslint_d", "prettierd" }
vim.g.neoformat_enabled_javascript = { "eslint_d", "prettierd" }

vim.g.neoformat_enabled_cpp = { "clang-format" }
vim.g.neoformat_enabled_arduino = { "clang-format" }

vim.g.neoformat_enabled_lua = { "stylua" }

vim.g.neoformat_json_jq = {
    exe = "jq",
    args = { "--indent 4" },
    stdin = true,
}
vim.g.neoformat_enabled_json = { "jq" }
