-- Set up nvim-cmp.
local cmp = require("cmp")

cmp.setup({
    -- snippet = {
    -- commented for now because I don't use a snippet engine
    -- I can probably stop installing 'hrsh7th/vim-vsnip' in plugins.lua
    --     -- REQUIRED - you must specify a snippet engine
    --     expand = function(args)
    --         vim.fn["vsnip#anonymous"](args.body)
    --     end,
    -- },
    mapping = cmp.mapping.preset.insert({
        ["<C-b>"] = cmp.mapping.scroll_docs(-4),
        ["<C-f>"] = cmp.mapping.scroll_docs(4),
        ["<C-Tab>"] = cmp.mapping.complete(),
        ["<C-e>"] = cmp.mapping.abort(),
        ["<CR>"] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
    }),
    sources = cmp.config.sources({
        { name = "nvim_lsp" },
        { name = "vsnip" },
        { name = "calc" },
        { name = "nvim_lsp_signature_help" },
        { name = "nvim_lua" },
    }, {
        { name = "buffer" },
    }),
})

-- Configure the completion for nvim builtin search /
-- (if you enabled `native_menu`, this won't work anymore)
cmp.setup.cmdline("/", {
    mapping = cmp.mapping.preset.cmdline(),
    sources = cmp.config.sources({
        { name = "nvim_lsp_document_symbol" },
    }, {
        { name = "buffer" },
    }),
})

-- Configure the completion for nvim builtin command line :
-- (if you enabled `native_menu`, this won't work anymore).
cmp.setup.cmdline(":", {
    mapping = cmp.mapping.preset.cmdline(),
    sources = cmp.config.sources({
        { name = "path" },
    }, {
        { name = "cmdline" },
    }),
})
