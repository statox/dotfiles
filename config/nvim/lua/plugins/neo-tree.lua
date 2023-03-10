require("neo-tree").setup({
    window = {
        position = "current",
        mappings = {
            ["-"] = "close_window"
        }
    },
    filesystem = {
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
