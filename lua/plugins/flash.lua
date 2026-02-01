return {
    "folke/flash.nvim",
    event = "VeryLazy",
    opts = {
        highlight = {
            backdrop = true,
            groups = {
                label = "FlashLabel",
            },
        },
    },
    config = function(_, opts)
        require("flash").setup(opts)
        vim.api.nvim_set_hl(0, "FlashLabel", { fg = "#000000", bg = "#FF8DA1", bold = true })
    end,
    keys = {
        { "s", mode = { "n", "x", "o" }, function() require("flash").jump() end, desc = "Flash" },
    },
}
