local M = {}

vim.opt.laststatus = 2

function M.time_since_last_update()
    if vim.fn.expand('%') == '' then
        return ''
    end
    if vim.b.term_title ~= nil then
        return ''
    end

    local seconds = vim.fn.localtime() - vim.fn.getftime(vim.fn.expand('%'))
    local status_time = ''
    local time_since = ''

    if seconds >= 86400 then
        time_since = '>' .. math.floor((seconds % 86400) / 3600) .. 'j'
    else
        local hours   = math.floor((seconds % 86400) / 3600)
        local minutes = math.floor((seconds % 3600) / 60)
        local secs    = seconds % 60

        time_since = (hours > 0) and (hours .. 'h') or ''
        time_since = time_since .. ((minutes > 0 or hours > 0) and (minutes .. 'm') or '')
        time_since = time_since .. secs .. 's'
        status_time = vim.fn.strftime('%R', vim.fn.getftime(vim.fn.expand('%'))) .. ' - '
    end

    return '[' .. status_time .. time_since .. ']'
end

local function set_status_line()
    local sl = ''

    if vim.b.term_title ~= nil then
        sl = sl .. '%#Error#%m%h%*'
        sl = sl .. '%#DiffAdd#%q%*'
        sl = sl .. '[%l/%L-%c]'
    end

    sl = sl .. '[%t]'
    sl = sl .. '%='
    sl = sl .. "%{v:lua.require('statusline').time_since_last_update()}"

    vim.opt.statusline = sl
end

set_status_line()

return M
