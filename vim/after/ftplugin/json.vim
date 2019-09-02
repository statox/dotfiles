" JSON ftplugin

" Use python module to format json with =
setlocal equalprg=python\ -m\ json.tool
setlocal formatprg=python\ -m\ json.tool

" setlocal equalprg=jq
" setlocal formatprg=jq
