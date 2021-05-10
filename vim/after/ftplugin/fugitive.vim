" Turn the current window into a floating window
function FloatIt()
    if !has('nvim')
        echoerr 'Floating window not supported'
        return
    endif

    " let widthPercent = 0.5
    let heightPercent = 0.8

    " Get the buffer to open in floating window
    let buf = bufnr()
    call nvim_win_close(0, v:false)

    " Get the current UI
    let ui = nvim_list_uis()[0]

    " let width = float2nr(ceil(ui.width * widthPercent))
    let width = 83
    let height = float2nr(ceil(ui.height * heightPercent))

    " Create the floating window
    let opts = {'relative': 'editor',
                \ 'width':  width,
                \ 'height': height,
                \ 'col': (ui.width/2) - (width/2),
                \ 'row': (ui.height/2) - (height/2),
                \ 'anchor': 'NW',
                \ 'style': 'minimal',
                \ }
    let win = nvim_open_win(buf, 1, opts)
endfunction

nnoremap <silent><buffer> g? :<C-u>h fugitive-map<CR>:call FloatIt()<CR>zt
