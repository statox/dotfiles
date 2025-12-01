-- Colorscheme Synchronization Between WezTerm and Neovim
--
-- This module watches the /tmp/colorscheme file for changes and updates
-- Neovim's colorscheme accordingly. This enables synchronized colorscheme
-- switching: when WezTerm's colorscheme is toggled (light/dark), Neovim
-- automatically updates to match.
--
-- See README.md for full documentation of this feature.

-- Watcher code taken from https://github.com/rktjmp/fwatch.nvim#
-- I got rid of the code I didn't need and only kept the core watcher function
-- If I need to watch more files in the future I should probably look into adding
-- the complete plugin instead

local uv = vim.loop

local make_default_error_cb = function(path, runnable)
  return function(error, _)
    error("fwatch.watch("..path..", "..runnable..")" ..
     "encountered an error: "..error)
  end
end

-- Watch path and calls on_event(filename, events) or on_error(error)
local function watch_with_function(path, on_event, on_error)
  local handle = uv.new_fs_event()

  -- These are just the default values
  local flags = {
    watch_entry = false, -- true = when dir, watch dir inode, not dir content
    stat = false, -- true = don't use inotify/kqueue but periodic check, not implemented
    recursive = false -- true = watch dirs inside dirs
  }

  local unwatch_cb = function()
    uv.fs_event_stop(handle)
  end

  local event_cb = function(err, filename, events)
    if err then
      on_error(error, unwatch_cb)
    else
      on_event(filename, events, unwatch_cb)
    end
  end

  uv.fs_event_start(handle, path, flags, event_cb)

  return handle
end

-- Check parameters and call the watch handler
local function do_watch(path, runnable)
    assert(type(runnable) == "table", "Unknown runnable type given to watch, must be a table {on_event = function, on_error = function}.")
    assert(runnable.on_event, "must provide on_event to watch")
    assert(type(runnable.on_event) == "function", "on_event must be a function")

    -- No on_error provided, make default
    if runnable.on_error == nil then
        table.on_error = make_default_error_cb(path, "on_event_cb")
    end

    return watch_with_function(
        path,
        runnable.on_event,
        runnable.on_error
    )
end

function read_colorscheme_file()
    local filepath = "/tmp/colorscheme"

    -- Read the first line of the file
    local content = vim.fn.readfile(filepath, '', 1)[1] or ""

    if string.match(content, "light") then
        return "light"
    end
    if string.match(content, "dark") then
        return "dark"
    end

    -- Default case
    return "dark"
end

function update_colorscheme()
    if read_colorscheme_file() == "light" then
        vim.g.colorsDefault = "dayfox"
        vim.g.colorsDiff = "dayfox"
    else
        vim.g.colorsDefault = "nightfox"
        vim.g.colorsDiff = "nordfox"
    end

    vim.cmd("colorscheme " .. vim.g.colorsDefault)
end

-- Setup the colorscheme on startup
update_colorscheme()

-- Update the colorscheme when wezterm updates the colorscheme file
do_watch('/tmp/colorscheme', {
    on_event = function()
        print('Colorscheme file has changed.')
        -- We wrap update_colorscheme in vim.schedule because the Vimscript function
        -- "readfile" must not be called in a fast event context
        vim.schedule(update_colorscheme)
    end
})
