return {
  "stevearc/aerial.nvim",
  dependencies = { "nvim-treesitter/nvim-treesitter" },
  keys = {
    { "<leader>o", "<cmd>AerialToggle!<CR>", desc = "Toggle outline" },
    { "{", "<cmd>AerialPrev<CR>", desc = "Previous symbol" },
    { "}", "<cmd>AerialNext<CR>", desc = "Next symbol" },
  },
  opts = {
    backends = { "lsp", "treesitter" },
    filter_kind = false,
    show_guides = true,
    close_on_select = true,
    on_first_symbols = function(bufnr)
      if vim.bo[bufnr].filetype == "markdown" then
        require("aerial").tree_set_collapse_level(bufnr, 99)
      else
        require("aerial").tree_set_collapse_level(bufnr, 1)
      end
    end,
    layout = {
      min_width = 30,
      default_direction = "left",
    },
  },
}
