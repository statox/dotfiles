-- status line configuration

-- Always display the status line, even if only one window is displayed
vim.opt.laststatus = 2

-- Use our custom status line
vim.cmd("call statusline#SetStatusLine()")
