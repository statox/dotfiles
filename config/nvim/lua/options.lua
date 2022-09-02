local opt = vim.opt

-- Allow to change buffer even if the current one is not written
opt.hidden = true

-- Better command-line completion
opt.wildmenu = true
opt.wildmode = {'longest','list','full'}

-- Do not show partial commands in the last line of the screen
opt.showcmd = false

-- Allow backspacing over autoindent, line breaks and start of insert action
opt.backspace = {'indent','eol','start'}

-- Raise dialog instead of failing a command because of unsaved changes
opt.confirm = true

-- Use visual bell instead of beeping when doing something wrong
opt.visualbell = true

-- Set the command window height to 2 lines, to avoid many cases of having to
-- "press <Enter> to continue"
opt.cmdheight = 2

-- Display line numbers on the left
opt.number = true
opt.relativenumber = false

-- automatically reload file when its modified outside vim
opt.autoread = true

 -- Allows vim to record more lines in history
opt.history = 5000

-- Swap and backup files are pretty annoying: get rid of them
opt.swapfile = false
opt.backup = false
opt.writebackup = false

-- make autocomplete case sensitive even if 'ignorecase' is on
opt.infercase = true
opt.completeopt = {'longest','menuone','preview'}

-- Show unviewable characters
opt.list = true
opt.listchars = {
    tab = '>-',
    trail = '.',
    eol = '¶'
}

-- Use the modelines (potentially a security concern)
opt.modeline = true

 -- Show tab line only if there are at least two tab pages
opt.showtabline = 1

 -- Set up undo dir
if vim.fn.has("persistent_undo") == 1 then
    opt.undodir = '~/.undodir/'
    opt.undofile = true
end

 -- Reduce update time (useful for GitGutter and COC.nvim)
opt.updatetime = 300

-- wildmode = list prevents wildoptions=pum to work
opt.inccommand = 'split'
opt.wildoptions = 'pum'
