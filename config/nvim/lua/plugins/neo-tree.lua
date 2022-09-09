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
            }
        }
    }
})

