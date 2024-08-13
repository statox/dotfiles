" ~/.vim/after/ftplugin
" vim:fdm=marker

" Guard {{{
    if exists("b:did_ftplugin_custom")
        finish
    endif
    let b:did_ftplugin_custom = 1
" }}}
" JS snippets {{{
    call common_web_settings#createMappings()
" }}}

" HACKY HACK
" Because typescript LSP server doesn't support workspace diagnostics its a PITA
" to get all the diagnostics of a project in a quickfix list
" Client says it should be done by server https://github.com/neovim/nvim-lspconfig/issues/989
" Server says it should be done by client https://github.com/typescript-language-server/typescript-language-server/issues/253
" So we hack:
" tsc --noEmit => Gets all the errors in a project + some informations which we don't want in the quickfix
"             | grep TS keeps only the lines with the filename and interesting info
"
" So we need to add the format to errorformat and the command TSAllErrors allows to populate the list
" Even if set errorformat is in this ftplugin it only adds the format once
set errorformat+=%f(%l\\,%c):\ error\ TS%n:\ %m
command -buffer TSAllErrors cexpr system('npx tsc --noEmit | grep TS') | copen
