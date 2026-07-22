if vim.fn.executable("npx") then
    vim.g.mkdp_filetypes = { "markdown" }
end
vim.g.mkdp_markdown_css = vim.fn.stdpath("config") .. "/lua/markdown/style.css"
vim.g.mkdp_highlight_css = vim.fn.stdpath("config") .. "/lua/markdown/highlight.css"
vim.g.mkdp_auto_close = false
-- vim.g.mkdp_port = 64432
