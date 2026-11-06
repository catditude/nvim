return {
  "stevearc/aerial.nvim",
  dependencies = { "nvim-treesitter/nvim-treesitter" },
  -- Loaded with the first file (not on <leader>o) so on_attach can map {/} per buffer.
  event = { "BufReadPre", "BufNewFile" },
  keys = {
    { "<leader>o", "<cmd>AerialToggle!<CR>", desc = "Toggle outline" },
  },
  opts = {
    -- {/} jump symbols only where aerial has symbols, and not in markdown, where
    -- they stay paragraph motions.
    on_attach = function(bufnr)
      if vim.bo[bufnr].filetype == "markdown" then return end
      vim.keymap.set("n", "{", "<cmd>AerialPrev<CR>", { buffer = bufnr, desc = "Previous symbol" })
      vim.keymap.set("n", "}", "<cmd>AerialNext<CR>", { buffer = bufnr, desc = "Next symbol" })
    end,
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
