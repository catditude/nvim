return {
    "folke/flash.nvim",
    opts = {
        highlight = {
            backdrop = true,
            groups = {
                label = "FlashLabel",
            },
        },
    },
    keys = {
        { "s", mode = { "n", "x", "o" }, function() require("flash").jump() end, desc = "Flash" },
    },
}
