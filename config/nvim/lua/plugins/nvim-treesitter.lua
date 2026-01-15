-- nvim-treesitter setup (new API - the old nvim-treesitter.configs module was removed)
require("nvim-treesitter").setup({
    -- Install parsers in the standard location
    install_dir = vim.fn.stdpath("data") .. "/site",
})

-- Install all parsers (equivalent to ensure_installed = "all")
-- You can also specify a list: { "lua", "javascript", "typescript", ... }
-- Timeout after 5 minutes
require("nvim-treesitter").install("all"):wait(300000)

-- Highlighting is now enabled by default in Neovim via vim.treesitter
-- No explicit configuration needed

-- Indentation: set indentexpr for treesitter-based indentation
vim.api.nvim_create_autocmd("FileType", {
    pattern = "*",
    callback = function()
        -- Only set if treesitter parser is available for this filetype
        local lang = vim.treesitter.language.get_lang(vim.bo.filetype)
        if lang and pcall(vim.treesitter.language.inspect, lang) then
            vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
        end
    end,
})

-- vim-matchup integration is configured on the matchup side now
-- The plugin automatically detects treesitter if available
