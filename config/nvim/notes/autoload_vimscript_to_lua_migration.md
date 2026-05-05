# Autoload Vimscript to Lua Migration

Migrated all `autoload/*.vim` files to Lua, eliminating the `autoload/` directory entirely.

`after/ftplugin/typescript.vim` was intentionally left untouched - it must stay in Vimscript
due to a Neovim bug with escaped commas in `vim.opt.errorformat:append()` (issues #29061 and
#20107, both still open as of 2026-05-06).

## What was migrated

### `autoload/utils.vim` and `autoload/help.vim` → inlined into `lua/commands.lua`

Both functions had a single call site in `commands.lua` and were short enough to inline.
`nvim_create_user_command` accepts a Lua function as its action, so the `call autoload#fn()`
Vimscript strings were replaced with direct Lua callbacks. No new files needed.

### `autoload/motion.vim` → `lua/motion.lua`

Ported `SkipOrH` and `SkipOrL` to a Lua module. The functions use `vim.fn.getpos`/`setpos`
and `vim.cmd("normal! ...")` which are direct equivalents of the Vimscript originals.

Keymaps in `mappings.lua` changed from `:call motion#SkipOrH()<CR>` strings to Lua function
references (`motion.skip_or_h`), which is cleaner and avoids the command-line roundtrip.

### `autoload/diff.vim` → `lua/helpers/diff.lua`

`vim.opt.diffexpr` requires a Vimscript expression string (not a Lua function). The solution
is `v:lua`, which lets Neovim call into a Lua module from a Vimscript expression:

```lua
vim.opt.diffexpr = "v:lua.require('helpers.diff').diff_w()"
```

The special variables `v:fname_in`, `v:fname_new`, `v:fname_out` that Neovim sets before
evaluating `diffexpr` are accessible from Lua as `vim.v.fname_in` etc.

### `autoload/statusline.vim` → `lua/statusline.lua`

`lua/statusline.lua` was previously just a 2-line shim that called the Vimscript function.
It now contains the full implementation.

The statusline format string uses `%{...}` to call a function dynamically on each redraw.
Since the function is now Lua, `v:lua` is used again:

```lua
sl = sl .. "%{v:lua.require('statusline').time_since_last_update()}"
```

`time_since_last_update` is exported from the module (`M.time_since_last_update`) so it is
accessible via `require`.
