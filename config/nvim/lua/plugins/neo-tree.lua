require("neo-tree").setup({
    window = {
        position = "current",
        mappings = {
            ["-"] = "close_window"
        }
    },
    filesystem = {
        -- bind_to_cwd = false, -- true creates a 2-way binding between vim's cwd and neo-tree's root
        window = {
            mappings = {
                ["%"] = "add",
                ["d"] = "add_directory",
                ["D"] = "delete",
                ["P"] = { "toggle_preview" },
                -- Temporary disable v to force myself to use s and S for splits
                ["v"] = "noop",
            }
        }
    }
})

vim.g.neo_tree_remove_legacy_commands = 1
