# Features

## Synchronized Colorscheme Toggling (WezTerm + Neovim)

This dotfiles configuration includes a feature that synchronizes colorscheme changes between WezTerm and Neovim, allowing me to toggle between light and dark modes that apply to both applications simultaneously.

### How it works

1. **Shared state file**: Both applications use `/tmp/colorscheme` as a shared state file that stores the current mode ("light" or "dark")

2. **WezTerm controls the toggle**:
   - WezTerm provides a `toggle_colorscheme()` function that switches between modes
   - When triggered, it writes the new mode to `/tmp/colorscheme` and reloads its configuration
   - The new colorscheme is applied: "dayfox" (light) or "nightfox" (dark)

3. **Neovim watches and reacts**:
   - Neovim uses a file watcher to monitor `/tmp/colorscheme` for changes
   - When the file is modified, it automatically reads the new mode and updates its colorscheme
   - Light mode uses "dayfox", dark mode uses "nightfox" (default) and "nordfox" (diff)

### Files involved

- `config/wezterm/colorscheme.lua`: Manages the colorscheme state and toggle functionality
    -  `config/wezterm/ui.lua` calls `colorscheme.init_colorschem()` which reads the file and returns the name of the colorscheme to use in the config
    - `config/wezterm/wezterm.lua` is responsible for calling `setup_ui()` from the `ui` module.
- `config/nvim/lua/colorscheme_watcher.lua`: Implements the file watcher and colorscheme updates for neovim

### Usage

Trigger the colorscheme toggle using your configured WezTerm keybinding. Both WezTerm and any running Neovim instances will update their colorschemes automatically.

