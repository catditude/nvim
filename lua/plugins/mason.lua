return {
  "mason-org/mason.nvim",
  opts = {},
  dependencies = {
    {
      "WhoIsSethDaniel/mason-tool-installer.nvim",
      opts = {
        -- Mason registry package names (not vim.lsp config names)
        ensure_installed = {
          "bash-language-server",
          "shellcheck", -- bashls delegates diagnostics here
          "shfmt",      -- bashls delegates formatting here
        },
        run_on_start = true,
        start_delay = 3000,
      },
    },
  },
}
