This is the plan generated and then applied by claude.

After applying this plan I had do update treesitter config which used a broken import.

# Migration Plan: Packer to Lazy.nvim

## Overview

This plan migrates your Neovim plugin management from packer.nvim to lazy.nvim while preserving all existing plugin configurations and behaviors.

## Key Differences Between Packer and Lazy.nvim

| Packer | Lazy.nvim | Notes |
|--------|-----------|-------|
| `use("author/repo")` | `{ "author/repo" }` | Basic plugin spec |
| `requires = {...}` | `dependencies = {...}` | Plugin dependencies |
| `run = "..."` | `build = "..."` | Post-install commands |
| `config = function()` | `config = function()` | Same, but prefer `opts` |
| `setup = function()` | `init = function()` | Runs before plugin loads |
| `after = "plugin"` | `dependencies` | Lazy handles load order automatically |
| `opt = true` | `lazy = true` | Lazy loading |
| `branch = "0.1.x"` | `branch = "0.1.x"` | Same |

**New in Lazy.nvim:**
- `opts = {}` - Preferred way to pass options to `require("plugin").setup(opts)`
- Automatic lazy-loading detection
- Built-in profiling and health checks

---

## Step-by-Step Migration

### Step 1: Modify `init.lua` - Add lazy.nvim bootstrap

Replace the current `require("plugins")` line with lazy.nvim bootstrap code.

**Before (current):**
```lua
require("plugins")
```

**After:**
```lua
-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

-- Setup lazy.nvim
require("lazy").setup("plugins")
```

Note: `require("lazy").setup("plugins")` will automatically load all lua files from `lua/plugins/` directory as plugin specs.


User note: I want the bootstrap code and the setup code in the same file `lua/plugins.lua`. This was `init.lua` keeps only the instruction `require("plugins")` and the logic around lazy.nvim is contained in a file.

---

### Step 2: Restructure the plugins directory

**Current structure:**
```
lua/
  plugins.lua           <- Main plugin list with packer
  plugins/
    cmp.lua             <- Plugin configs (called after packer loads)
    comment.lua
    lsp.lua
    neo-tree.lua
    neoformat.lua
    nvim-treesitter.lua
    telescope.lua
    vim-test.lua
```

**New structure for lazy.nvim:**
```
lua/
  plugins/
    init.lua            <- Main plugin list (replaces plugins.lua)
    cmp.lua             <- Can stay as config or be merged into init.lua
    comment.lua
    lsp.lua
    neo-tree.lua
    neoformat.lua
    nvim-treesitter.lua
    telescope.lua
    vim-test.lua
```

**Option A (Recommended): Single file approach**
Move all plugin specs into `lua/plugins/init.lua` with inline configs.

**Option B: Multi-file approach**
Each file in `lua/plugins/` returns a plugin spec table. Lazy.nvim auto-loads them all.

I recommend **Option A** for your setup since:
- Your current config files mostly just call `require("plugin").setup({...})`
- Keeps all plugin declarations in one place for easy overview
- Matches your current mental model (one file listing all plugins)

User note: Implement option A

---

### Step 3: Convert each plugin spec

Here's how each plugin in your current `plugins.lua` should be converted:

#### 3.1 Nightfox (colorscheme)
```lua
-- Packer
use({
    "EdenEast/nightfox.nvim",
    config = require("nightfox").setup({
        options = { dim_inactive = true },
    }),
})

-- Lazy.nvim
{
    "EdenEast/nightfox.nvim",
    lazy = false,      -- Load during startup for colorscheme
    priority = 1000,   -- Load before other plugins
    opts = {
        options = { dim_inactive = true },
    },
},
```

#### 3.2 Simple plugins (no config)
```lua
-- Packer
use("numToStr/Comment.nvim")
use("tpope/vim-surround")

-- Lazy.nvim
{ "numToStr/Comment.nvim" },
{ "tpope/vim-surround" },
```

#### 3.3 Beacon (with config function)
```lua
-- Packer
use({
    "danilamihailov/beacon.nvim",
    config = function()
        require("beacon").setup({ ... })
    end,
})

-- Lazy.nvim
{
    "danilamihailov/beacon.nvim",
    opts = {
        enabled = function()
            local disabled_ft = { "neo-tree", "help" }
            for _, ft in ipairs(disabled_ft) do
                if vim.bo.ft == ft then return false end
            end
            return true
        end,
        width = 20,
        min_jump = 1,
        highlight = { bg = "red", ctermbg = 9 },
    },
},
```

#### 3.4 Neo-tree (with dependencies)
```lua
-- Packer
use({
    "nvim-neo-tree/neo-tree.nvim",
    requires = {
        "nvim-lua/plenary.nvim",
        "nvim-tree/nvim-web-devicons",
        "MunifTanjim/nui.nvim",
    },
})

-- Lazy.nvim
{
    "nvim-neo-tree/neo-tree.nvim",
    dependencies = {
        "nvim-lua/plenary.nvim",
        "nvim-tree/nvim-web-devicons",
        "MunifTanjim/nui.nvim",
    },
    config = function()
        require("plugins.neo-tree")
    end,
},
```

#### 3.5 Treesitter (with build/run command)
```lua
-- Packer
use({ "nvim-treesitter/nvim-treesitter", run = ":TSUpdate" })

-- Lazy.nvim
{
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function()
        require("plugins.nvim-treesitter")
    end,
},
```

#### 3.6 Telescope (with branch and dependencies)
```lua
-- Packer
use({
    "nvim-telescope/telescope.nvim",
    branch = "0.1.x",
    requires = {
        "nvim-lua/plenary.nvim",
        "nvim-telescope/telescope-fzf-native.nvim",
    },
})

-- Lazy.nvim
{
    "nvim-telescope/telescope.nvim",
    branch = "0.1.x",
    dependencies = {
        "nvim-lua/plenary.nvim",
        { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
    },
    config = function()
        require("plugins.telescope")
    end,
},
```

#### 3.7 Markdown-preview (with function run)
```lua
-- Packer
use({
    "iamcco/markdown-preview.nvim",
    run = function() vim.fn["mkdp#util#install"]() end,
})

-- Lazy.nvim
{
    "iamcco/markdown-preview.nvim",
    build = function() vim.fn["mkdp#util#install"]() end,
},
```

#### 3.8 render-markdown (with after)
```lua
-- Packer
use({
    'MeanderingProgrammer/render-markdown.nvim',
    after = { 'nvim-treesitter' },
    requires = { 'nvim-tree/nvim-web-devicons', opt = true },
    config = function()
        require('render-markdown').setup({ ... })
    end,
})

-- Lazy.nvim (after is handled automatically via dependencies)
{
    'MeanderingProgrammer/render-markdown.nvim',
    dependencies = {
        'nvim-treesitter/nvim-treesitter',
        'nvim-tree/nvim-web-devicons',
    },
    opts = {
        completions = { lsp = { enabled = true } },
    },
},
```

#### 3.9 LSP + Mason setup
```lua
-- Lazy.nvim
{
    "neovim/nvim-lspconfig",
    dependencies = {
        "williamboman/mason.nvim",
        "williamboman/mason-lspconfig.nvim",
    },
    config = function()
        require("plugins.lsp")
    end,
},
```

#### 3.10 nvim-cmp with all sources
```lua
{
    "hrsh7th/nvim-cmp",
    dependencies = {
        "neovim/nvim-lspconfig",
        "hrsh7th/vim-vsnip",
        "hrsh7th/cmp-nvim-lsp",
        "hrsh7th/cmp-buffer",
        "hrsh7th/cmp-path",
        "hrsh7th/cmp-cmdline",
        "hrsh7th/cmp-vsnip",
        "hrsh7th/cmp-calc",
        "hrsh7th/cmp-nvim-lsp-document-symbol",
        "hrsh7th/cmp-nvim-lsp-signature-help",
        "hrsh7th/cmp-nvim-lua",
    },
    config = function()
        require("plugins.cmp")
    end,
},
```

---

### Step 4: Handle plugin config files

Your existing config files in `lua/plugins/` can be kept as-is. They will be loaded via `require("plugins.xxx")` in the `config` function of each plugin spec.

The files that need minor changes:

1. **`telescope.lua`** - Currently returns a module. This is fine, just make sure it's required in the plugin spec.

2. **`lsp.lua`** - Calls `require("mason").setup()` and `require("mason-lspconfig").setup()`. This is fine since Mason plugins are listed as dependencies.

---

### Step 5: Delete packer-related code

1. Delete the `ensure_packer` function from `plugins.lua`
2. Delete the `packer.startup(function(use) ... end)` wrapper

---

### Step 6: Clean up packer installation

Make sure you ask the user first!
After confirming lazy.nvim works:

```bash
rm -rf ~/.local/share/nvim/site/pack/packer
```

---

## Complete New `lua/plugins/init.lua`

Here's the full converted file:

```lua
return {
    -- Colorscheme
    {
        "EdenEast/nightfox.nvim",
        lazy = false,
        priority = 1000,
        opts = {
            options = { dim_inactive = true },
        },
    },

    -- Comment plugin
    {
        "numToStr/Comment.nvim",
        config = function()
            require("plugins.comment")
        end,
    },

    -- Surround text
    { "tpope/vim-surround" },

    -- Quick substitutions
    { "svermeulen/vim-subversive" },

    -- Text alignment
    { "godlygeek/tabular" },

    -- Git wrapper
    { "tpope/vim-fugitive" },

    -- Git diff in gutter
    { "mhinz/vim-signify" },

    -- Online doc links
    { "statox/GOD.vim" },

    -- Devicons
    { "nvim-tree/nvim-web-devicons" },

    -- Cursor beacon
    {
        "danilamihailov/beacon.nvim",
        opts = {
            enabled = function()
                local disabled_ft = { "neo-tree", "help" }
                for _, ft in ipairs(disabled_ft) do
                    if vim.bo.ft == ft then return false end
                end
                return true
            end,
            width = 20,
            min_jump = 1,
            highlight = { bg = "red", ctermbg = 9 },
        },
    },

    -- Compare lines
    { "statox/vim-compare-lines" },

    -- Indent guides
    { "lukas-reineke/indent-blankline.nvim" },

    -- Nunjucks/Jinja2 syntax
    { "Glench/Vim-Jinja2-Syntax" },

    -- Modern matchit
    { "andymass/vim-matchup" },

    -- Test runner
    {
        "vim-test/vim-test",
        config = function()
            require("plugins.vim-test")
        end,
    },

    -- Markdown preview
    {
        "iamcco/markdown-preview.nvim",
        build = function() vim.fn["mkdp#util#install"]() end,
    },

    -- Render markdown
    {
        'MeanderingProgrammer/render-markdown.nvim',
        dependencies = {
            'nvim-treesitter/nvim-treesitter',
            'nvim-tree/nvim-web-devicons',
        },
        opts = {
            completions = { lsp = { enabled = true } },
        },
    },

    -- Aerial (symbols outline)
    {
        "stevearc/aerial.nvim",
        opts = {
            layout = {
                default_direction = "prefer_left",
            },
        },
    },

    -- Neo-tree (file explorer)
    {
        "nvim-neo-tree/neo-tree.nvim",
        dependencies = {
            "nvim-lua/plenary.nvim",
            "nvim-tree/nvim-web-devicons",
            "MunifTanjim/nui.nvim",
        },
        config = function()
            require("plugins.neo-tree")
        end,
    },

    -- Treesitter
    {
        "nvim-treesitter/nvim-treesitter",
        build = ":TSUpdate",
        config = function()
            require("plugins.nvim-treesitter")
        end,
    },

    -- Telescope
    {
        "nvim-telescope/telescope.nvim",
        branch = "0.1.x",
        dependencies = {
            "nvim-lua/plenary.nvim",
            { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
        },
        config = function()
            require("plugins.telescope")
        end,
    },

    -- LSP
    {
        "neovim/nvim-lspconfig",
        dependencies = {
            "williamboman/mason.nvim",
            "williamboman/mason-lspconfig.nvim",
        },
        config = function()
            require("plugins.lsp")
        end,
    },

    -- Formatter
    {
        "sbdchd/neoformat",
        config = function()
            require("plugins.neoformat")
        end,
    },

    -- Completion
    {
        "hrsh7th/nvim-cmp",
        dependencies = {
            "neovim/nvim-lspconfig",
            "hrsh7th/vim-vsnip",
            "hrsh7th/cmp-nvim-lsp",
            "hrsh7th/cmp-buffer",
            "hrsh7th/cmp-path",
            "hrsh7th/cmp-cmdline",
            "hrsh7th/cmp-vsnip",
            "hrsh7th/cmp-calc",
            "hrsh7th/cmp-nvim-lsp-document-symbol",
            "hrsh7th/cmp-nvim-lsp-signature-help",
            "hrsh7th/cmp-nvim-lua",
        },
        config = function()
            require("plugins.cmp")
        end,
    },
}
```

---

## Updated `init.lua`

User note: This is wrong! `init.lua` will not change it is `lua/plugins.lua` which will hold this logic!
```lua
vim.api.nvim_command("set runtimepath^=~/.vim runtimepath+=~/.vim/after")
vim.api.nvim_command("let &packpath = &runtimepath")

-- Reset path to default and add subdirectories to path
vim.api.nvim_command('set path& | let &path .= "**"')

-- Detect the type of a file automatically
-- and use the ftplugin and indent plugin for this ft
vim.api.nvim_command("filetype plugin indent on")
-- Enable syntax highlighting
vim.api.nvim_command("syntax on")

-- Custom settings in lua
require("options")
require("mappings")
require("commands")
require("abbreviations")
require("statusline")
require("autocommands")

-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
    local lazyrepo = "https://github.com/folke/lazy.nvim.git"
    local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
    if vim.v.shell_error ~= 0 then
        vim.api.nvim_echo({
            { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
            { out, "WarningMsg" },
            { "\nPress any key to exit..." },
        }, true, {})
        vim.fn.getchar()
        os.exit(1)
    end
end
vim.opt.rtp:prepend(lazypath)

-- Setup lazy.nvim (loads all specs from lua/plugins/)
require("lazy").setup("plugins")

-- Post-plugin configuration
require("colorscheme_custom")
require("colorscheme_watcher")
require("diffsettings")
```

---

## Testing the Migration

1. Backup your current config: `cp -r ~/.config/nvim ~/.config/nvim.bak`
2. Apply the changes
3. Start Neovim - lazy.nvim will auto-install and show its UI
4. Run `:checkhealth lazy` to verify installation
5. Run `:Lazy` to see the plugin manager UI
6. Test each plugin works as expected

---

## Rollback Plan

If something goes wrong:
1. Restore backup: `rm -rf ~/.config/nvim && mv ~/.config/nvim.bak ~/.config/nvim`
2. Remove lazy.nvim data: `rm -rf ~/.local/share/nvim/lazy`

---

## Summary of Changes

| Action | Files Affected |
|--------|----------------|
| Add lazy.nvim bootstrap | `init.lua` |
| Create new plugin specs | `lua/plugins/init.lua` (new) |
| Delete packer file | `lua/plugins.lua` (delete) |
| Keep existing configs | `lua/plugins/*.lua` (unchanged) |

Total files to modify: 2 (lua/plugins.lua, new plugins/init.lua)
Total files to delete: 0
Total files unchanged: 8 (all config files in lua/plugins/)
