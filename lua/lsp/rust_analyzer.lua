---@type vim.lsp.Config
return {
  cmd = { 'rust-analyzer' },
  filetypes = { 'rust' },
  root_markers = { 'Cargo.toml', 'rust-project.json', '.git' },
  settings = {
    ['rust-analyzer'] = {
      check = {
        command = 'clippy', -- Use clippy instead of cargo check
      },
      -- Native diagnostics repeat what clippy reports on save (autosave runs it
      -- ~1s after each edit), so every error showed twice.
      diagnostics = { enable = false },
    },
  },
}
