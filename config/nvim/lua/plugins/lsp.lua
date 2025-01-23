-- NVIM LSP config

local function organize_imports()
    local params = {
        command = "_typescript.organizeImports",
        arguments = { vim.api.nvim_buf_get_name(0) },
        title = "",
    }
    vim.lsp.buf.execute_command(params)
end

-- on_attach function used after the language server attaches to the current buffer
local on_attach = function(client, bufnr)
    -- Enable completion triggered by <c-x><c-o>
    vim.api.nvim_buf_set_option(bufnr, "omnifunc", "v:lua.vim.lsp.omnifunc")

    -- Mappings.
    -- See `:help vim.lsp.*` for documentation on any of the below functions
    local bufopts = { noremap = true, silent = true, buffer = bufnr }
    vim.keymap.set("n", "gd", "<cmd>Telescope lsp_definitions<CR>", bufopts)
    vim.keymap.set("n", "gD", ":vsplit <CR>: lua vim.lsp.buf.definition() <CR>: wincmd T<CR>", bufopts)
    vim.keymap.set("n", "K", vim.lsp.buf.hover, bufopts)
    vim.keymap.set("n", "<C-k>", vim.lsp.buf.signature_help, bufopts)
    vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, bufopts)
    vim.keymap.set("n", "<leader>a", vim.lsp.buf.code_action, bufopts)
    vim.keymap.set("n", "gr", '<cmd>lua require("telescope.builtin").lsp_references({show_line = false})<CR>', bufopts)
    vim.keymap.set("n", "gR", '<cmd>lua require("telescope.builtin").lsp_references({trim_text = true})<CR>', bufopts)
    vim.keymap.set("n", "<leader>f", vim.lsp.buf.format, bufopts)

    vim.keymap.set("n", "[c", vim.diagnostic.goto_prev, bufopts)
    vim.keymap.set("n", "]c", vim.diagnostic.goto_next, bufopts)
    vim.keymap.set("n", "<leader>d", "<cmd>Telescope diagnostics<CR>", bufopts)

    -- Show line diagnostics automatically in hover window
    vim.api.nvim_create_autocmd({ "CursorHold" }, {
        buffer = bufnr,
        callback = function()
            local opts = {
                focusable = false,
                close_events = { "BufLeave", "CursorMoved", "InsertEnter", "FocusLost" },
                border = "rounded",
                source = "if_many",
                prefix = function(_, i, total)
                    if total > 1 then
                        return i .. "/" .. total .. " "
                    end
                    return " "
                end,
                scope = "line",
            }
            vim.diagnostic.open_float(nil, opts)
        end,
    })
end

local lsp_flags = {
    -- This is the default in Nvim 0.7+
    debounce_text_changes = 150,
}

-- mason-lspconfig's `ensure_installed` option doesn't support packages
-- other than LSP servers https://github.com/williamboman/mason-lspconfig.nvim/issues/83
-- So the folowing formatters needs to be installed through the :Mason
-- command interface

-- prettier
-- prettierd
-- stylua

local serversToInstall = {
    "ansiblels",
    "arduino_language_server",
    "bashls",
    "clangd", -- required by arduino_language_server
    "cssls",
    "dockerls",
    "eslint",
    "html",
    "prosemd_lsp", -- markdown
    -- "pylsp",
    "pyright",
    "ruff",
    "sqlls",
    "svelte",
    "terraformls",
    "ts_ls",
    "vimls",
}

-- IMPORTANT TO LOAD BEFORE lspconfig
require("mason").setup()
require("mason-lspconfig").setup({
    automatic_installation = true, -- Look like it still requires to run :Mason to install a new server after it is added to the list
    ensure_installed = serversToInstall,
})

-- Set up cpm_nvim_lsp as a completion source for lsp servers
local capabilities = require("cmp_nvim_lsp").default_capabilities()

-- Set up the different lsp server installed by mason with lspconfig
for _, server in ipairs(serversToInstall) do
    local opts = {
        on_attach = on_attach,
        flags = lsp_flags,
        capabilities = capabilities,
    }

    if server == "ts_ls" then
        opts.commands = {
            OrganizeImports = {
                organize_imports,
                description = "Organize Imports",
            },
        }
    end

    if server == "terraformls" then
        opts.filetypes = { "tf", "terraform" }
    end

    -- if server == "arduino_language_server" then
    --     opts.filetypes = { "arduino", "cpp" }
    -- end

    -- if server == "clangd" then
    --     opts.filetypes = { "cpp", "arduino" }
    -- end

    require("lspconfig")[server].setup(opts)
end

-- Disable virtual_text since it's redundant with the autocmd showing them in the floating window
vim.diagnostic.config({
    virtual_text = false,
})
