vim.api.nvim_exec2(
    [[
    " I should turn that to lua but I need to figure out the substitution with regex
    function! MochaTransform(cmd) abort
      let cmd = substitute(a:cmd, "node_modules/.bin/mocha", "debug=true pnpm run test --", "")
      let cmd2 = substitute(cmd, "-r ts-node/register [^ ]*", "", "")
      return cmd2
    endfunction
]],
    {}
)

local MochaTransformLua = vim.fn["MochaTransform"]

vim.g["test#custom_transformations"] = { mocha = MochaTransformLua }
vim.g["test#transformation"] = "mocha"
vim.g["test#strategy"] = "neovim"
vim.g["test#neovim#start_normal"] = 1
vim.g["test#neovim#term_position"] = "botright vert"

local command = vim.api.nvim_create_user_command

command("TN", "TestNearest", { force = true })
command("TL", "TestLast", { force = true })

vim.keymap.set("n", "<leader>tn", ":TN<CR>", { noremap = true })
vim.keymap.set("n", "<leader>tl", ":TL<CR>", { noremap = true })
