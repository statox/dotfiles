" Only do this when not done yet for this buffer
if exists("b:did_custom_ftplugin")
    finish
endif
let b:did_custom_ftplugin = 1

setlocal wrap
