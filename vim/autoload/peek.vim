" Open the current buffer in a floating window
function! peek#floating() abort
    " Define the size of the floating window
    let widthPercentage = 0.8
    let heightPercentage = 0.8

    " Create the scratch buffer displayed in the floating window
    let buf = nvim_get_current_buf()

    let ui = nvim_list_uis()[0]
    let width = float2nr(ui.width * widthPercentage)
    let height = float2nr(ui.height * heightPercentage)

    " Create the floating window
    let ui = nvim_list_uis()[0]
    let opts = {'relative': 'editor',
                \ 'width': width,
                \ 'height': height,
                \ 'col': (ui.width/2) - (width/2),
                \ 'row': (ui.height/2) - (height/2),
                \ 'anchor': 'NW',
                \ 'style': 'minimal',
                \ }

    " Save the important options of the current window to apply them to the peek window
    let options_to_save = ['number', 'relativenumber']
    let options_values = {}
    for option in options_to_save
        let options_values[option] = nvim_win_get_option(0, option)
    endfor

    " Open the peek window
    let win = nvim_open_win(buf, 1, opts)

    " Copy the saved options to the peek window
    for option in options_to_save
        call nvim_win_set_option(win, option, options_values[option])
    endfor
    norm! zz
endfunction
