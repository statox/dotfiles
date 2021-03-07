function! breakhabits#createmappings(keys, message) abort
    for key in a:keys
        call nvim_set_keymap('n', key, ':call BreakHabitsWindow(' . string(a:message). ')<CR>', {'silent': v:true})
    endfor
endfunction

function! BreakHabitsWindow(message) abort
    " Get the size of the current UI
    let ui = nvim_list_uis()[0]
    let width = 50
    let height = 10

    " Create the scratch buffer displayed in the floating window
    let buf = nvim_create_buf(v:false, v:true)

    " Create the lines in the buffer
    " call nvim_buf_set_lines(buf, 0, height-1, v:false, map(range(height), {-> repeat(' ', 10)}))

    " Create the lines to draw a box
    let horizontal_border = '+' . repeat('-', width - 2) . '+'
    let empty_line = '|' . repeat(' ', width - 2) . '|'
    let lines = flatten([horizontal_border, map(range(height-2), 'empty_line'), horizontal_border])
    " Set the box in the buffer
    call nvim_buf_set_lines(buf, 0, -1, v:false, lines)

    " Create the lines for the centered message and put them in the buffer
    let message_lines = map(a:message, '"|" . repeat(" ", (width - 2 - len(v:val))/2) . v:val . repeat(" ", (width - 2 - len(v:val))/2) . "|"')
    " let message_lines = map(a:message, 'repeat(" ", (width - len(v:val))/2) . v:val . repeat(" ", (width - len(v:val))/2)')
    call nvim_buf_set_lines(buf, height/2-len(message_lines)/2, height/2-len(message_lines)/2+len(message_lines), v:false, message_lines)

    " Set mappings in the buffer to close the window easily
    let closingKeys = ['<Esc>', '<CR>', '<Leader>']
    for closingKey in closingKeys
        call nvim_buf_set_keymap(buf, 'n', closingKey, ':close<CR>', {'silent': v:true, 'nowait': v:true})
    endfor

    " Create the floating window
    let opts = {'relative': 'editor',
                \ 'width': width,
                \ 'height': height,
                \ 'col': (ui.width/2) - (width/2),
                \ 'row': (ui.height/2) - (height/2),
                \ 'anchor': 'NW',
                \ 'style': 'minimal',
                \ }
    let win = nvim_open_win(buf, 1, opts)

    " Change highlight
    call nvim_win_set_option(win, 'winhl', 'Normal:Error')
endfunction

