local M = {}

function M.diff_w()
    local opt = ""
    if vim.o.diffopt:find("icase") then
        opt = opt .. "--ignore-case "
    end
    if vim.o.diffopt:find("iwhite") then
        opt = opt .. "--ignore-all-space "
        opt = opt .. "--ignore-blank-lines "
        opt = opt .. "--ignore-space-change "
    end
    vim.fn.system(
        "diff -a --binary " .. opt
        .. vim.v.fname_in .. " "
        .. vim.v.fname_new .. " > "
        .. vim.v.fname_out
    )
end

return M
