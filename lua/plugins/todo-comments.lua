return {
    "folke/todo-comments.nvim",
    event = "VimEnter",
    dependencies = { "nvim-lua/plenary.nvim" },
    opts = {
        colors = {
            error = { "#ff005f" },
            warning = { "#ffffaf" },
            info = { "#A2CFFE" },
            hint = { "#9EB294" },
            default = { "#dfafff" },
            test = { "#F0C4C8" },
        },
    },
    keys = {
        { "]t", function() require("todo-comments").jump_next() end, desc = "Next todo" },
        { "[t", function() require("todo-comments").jump_prev() end, desc = "Previous todo" },
    },
}
