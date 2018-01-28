" Open the help buffer in a vertical split
function! help#VerticalHelp(topic)
    execute "vertical botright help " . a:topic
    execute "vertical resize 78"
endfunction
