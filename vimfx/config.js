//Define the hint chars
vimfx.set('hints.chars', 'hjlyubn')

// Mapping function
let nmap = (shortcuts, command, custom=false) => {
  vimfx.set(`${custom ? 'custom.' : ''}mode.normal.${command}`, shortcuts)
}

// Tab navigation
nmap('h'        , 'tab_select_previous')
nmap('l'        , 'tab_select_next')
nmap('0'        , 'tab_select_first')
nmap('$'        , 'tab_select_last')
nmap('<space>h' , 'tab_close')
nmap('<space>l' , 'tab_new_after_current')
nmap('u'        , 'tab_restore')


//Search mode
nmap('a/' , 'find')
nmap('/'  , 'find_highlight_all')

//prev-next
nmap('<backspace>'   , 'history_back')
nmap('<s-backspace>' , 'history_forward')

//Following links
nmap('<space>k' , 'follow_in_tab')
nmap("<space>j", "follow")

//Interaction with hints
nmap('Y'  , 'copy_current_url')
nmap('yy' , 'copy_current_url')

//Unmap stuff for convenience
nmap('' , 'scroll_left')
nmap('' , 'scroll_right')
nmap('' , 'scroll_page_down')
nmap('' , 'scroll_page_up')
nmap('' , 'scroll_to_left')
nmap('' , 'scroll_to_right')
nmap('' , 'element_text_caret')
nmap('' , 'paste_and_go')

//Private window
nmap('pw' , 'window_new_private')
