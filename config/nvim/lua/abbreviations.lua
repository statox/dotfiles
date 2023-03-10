-- Abbreviations for common mispelling

vim.cmd("inoreabbrev clog console.log")
vim.cmd("inoreabbrev syncrho synchro")
vim.cmd("inoreabbrev syncrhonize synchronize")
vim.cmd("inoreabbrev syncrhonisation synchronisation")
vim.cmd("cnoreabbrev <expr> Set (getcmdtype() == ':' && getcmdline() =~ '^Set$')? 'set' : 'Set'")
