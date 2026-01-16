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
local on_attach = function(args)
    local bufnr = args.buf
    local client = vim.lsp.get_client_by_id(args.data.client_id)

    if client.server_capabilities.completionProvider then
        -- -- Enable completion triggered by <c-x><c-o>
        vim.bo[bufnr].omnifunc = "v:lua.vim.lsp.omnifunc"
    end
    if client.server_capabilities.definitionProvider then
        vim.bo[bufnr].tagfunc = "v:lua.vim.lsp.tagfunc"
    end

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
vim.api.nvim_create_autocmd("LspAttach", { callback = on_attach });

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
    "docker_language_server",
    "dockerls",
    "eslint",
    "harper_ls", -- General grammar check
    "html",
    "pylsp", -- run :PylspInstall pylsp-mypy
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

    -- if server == "docker_language_server" then
    --     -- Files `docker-compose.yml` take the yaml filetype so I had to add it here
    --     -- TODO: Ideally make them have the ft yaml.docker-compose which is automatically
    --     -- used by this lsp
    --     opts.filetypes = { "yaml", "Dockerfile" }
    -- end

    if server == "terraformls" then
        opts.filetypes = { "tf", "terraform" }
    end

    if server == "harper_ls" then
        -- opts.filetypes = { "c", "cpp", "css", "gitcommit", "html", "javascript", "lua", "markdown", "python", "svelte", "toml", "typescript", "typescriptreact" }
        opts.filetypes = {"markdown"}
    end

    -- if server == "arduino_language_server" then
    --     opts.filetypes = { "arduino", "cpp" }
    -- end

    -- if server == "clangd" then
    --     opts.filetypes = { "cpp", "arduino" }
    -- end

    vim.lsp.config(server, opts)
    vim.lsp.enable({server})
end

-- Disable virtual_text since it's redundant with the autocmd showing them in the floating window
vim.diagnostic.config({
    virtual_text = false,
})
