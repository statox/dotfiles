-- NVIM LSP config

-- on_attach function used after the language server attaches to the current buffer
local on_attach = function(client, bufnr)
  -- Enable completion triggered by <c-x><c-o>
  vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')

  -- Mappings.
  -- See `:help vim.lsp.*` for documentation on any of the below functions
  local bufopts = { noremap=true, silent=true, buffer=bufnr }
  vim.keymap.set('n', 'gd',  '<cmd>Telescope lsp_definitions<CR>', bufopts)
  vim.keymap.set('n', 'gD', ':execute "tabnew +" . line(".") . " %"<CR>:Telescope lsp_definitions<CR>', bufopts)
  vim.keymap.set('n', 'K', vim.lsp.buf.hover, bufopts)
  vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, bufopts)
  vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, bufopts)
  vim.keymap.set('n', '<leader>D', vim.lsp.buf.type_definition, bufopts)
  vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, bufopts)
  vim.keymap.set('n', '<leader>a', vim.lsp.buf.code_action, bufopts)
  vim.keymap.set('n', 'gr', '<cmd>Telescope lsp_references<CR>', bufopts)
  vim.keymap.set('n', '<leader>f', vim.lsp.buf.formatting, bufopts)

  vim.keymap.set('n', '[c', vim.diagnostic.goto_prev, bufopts)
  vim.keymap.set('n', ']c', vim.diagnostic.goto_next, bufopts)
  vim.keymap.set('n', '<leader>d', vim.diagnostic.setloclist, bufopts)

  -- Show line diagnostics automatically in hover window
  vim.api.nvim_create_autocmd({"CursorHold"}, {
    buffer = bufnr,
    callback = function()
      local opts = {
        focusable = false,
        close_events = { "BufLeave", "CursorMoved", "InsertEnter", "FocusLost" },
        border = 'rounded',
        source = 'if_many',
        prefix = function(_, i, total)
            if (total > 1) then
                return i .. '/' .. total .. ' '
            end
            return ' '
        end,
        scope = 'line',
      }
      vim.diagnostic.open_float(nil, opts)
    end
  })
end

local lsp_flags = {
  -- This is the default in Nvim 0.7+
  debounce_text_changes = 150,
}

-- Set up nvim-cmp.
local cmp = require'cmp'

cmp.setup({
    snippet = {
        -- REQUIRED - you must specify a snippet engine
        expand = function(args)
            vim.fn["vsnip#anonymous"](args.body)
        end,
    },
    window = {
        -- completion = cmp.config.window.bordered(),
        -- documentation = cmp.config.window.bordered(),
    },
    mapping = cmp.mapping.preset.insert({
        ['<C-b>'] = cmp.mapping.scroll_docs(-4),
        ['<C-f>'] = cmp.mapping.scroll_docs(4),
        ['<C-Space>'] = cmp.mapping.complete(),
        ['<C-e>'] = cmp.mapping.abort(),
        ['<CR>'] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
    }),
    sources = cmp.config.sources({
        { name = 'nvim_lsp' },
        { name = 'vsnip' },
        { name = 'calc' },
        { name = 'nvim_lsp_signature_help' }
    }, {
            { name = 'buffer' },
        })
})

-- Use buffer source for `/` (if you enabled `native_menu`, this won't work anymore).
cmp.setup.cmdline('/', {
    mapping = cmp.mapping.preset.cmdline(),
    sources = cmp.config.sources({
        { name = 'nvim_lsp_document_symbol' }
    }, {
            { name = 'buffer' }
        })
})

-- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
cmp.setup.cmdline(':', {
    mapping = cmp.mapping.preset.cmdline(),
    sources = cmp.config.sources({
        { name = 'path' }
    }, {
            { name = 'cmdline' }
        })
})

local serversToInstall = {
    'ansiblels',
    'bashls',
    'cssls',
    'dockerls',
    'html',
    'prosemd_lsp', -- markdown
    'svelte',
    'terraformls',
    'tsserver',
    'sumneko_lua',
    'sqlls',
    'vimls'
}

-- IMPORTANT TO LOAD BEFORE lspconfig
require("mason").setup()
require("mason-lspconfig").setup({
    automatic_installation = true, -- Look like it still requires to run :Mason to install a new server after it is added to the list
    ensure_installed = serversToInstall
})

-- Set up cpm_nvim_lsp as a completion source for lsp servers
local capabilities = require('cmp_nvim_lsp').update_capabilities(vim.lsp.protocol.make_client_capabilities())

-- Set up the different lsp server installed by mason with lspconfig
for _, server in ipairs(serversToInstall) do
    local opts = {
        on_attach = on_attach,
        flags = lsp_flags,
        capabilities = capabilities
    };

    if server == 'sumneko_lua' then
        opts.settings = {
            Lua = {
                diagnostics = {
                    -- Avoid "undefined global" warnings for vim in neovim config
                    globals = { 'vim' }
                }
            }
        }
    end

    require('lspconfig')[server].setup(opts)
end

-- Disable virtual_text since it's redundant with the autocmd showing them in the floating window
vim.diagnostic.config({
  virtual_text = false,
})
