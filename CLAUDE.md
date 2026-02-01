# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This is a Neovim configuration using **lazy.nvim** as the plugin manager. The configuration is minimal and modular.

## Architecture

```
init.lua              → Entry point, loads lazy_init and lsp_setup
lua/lazy_init.lua     → Bootstraps lazy.nvim, imports plugins from lua/plugins/
lua/lsp_setup.lua     → Native LSP configuration (enables servers, keymaps)
lua/plugins/*.lua     → Plugin specifications (one file per plugin or category)
lsp/*.lua             → LSP server configs (Neovim 0.11 native format)
lazy-lock.json        → Locked plugin versions for reproducibility
```

## Plugin Management

- Plugin manager: [lazy.nvim](https://github.com/folke/lazy.nvim)
- Plugin specs go in `lua/plugins/` as Lua files returning a table
- lazy.nvim auto-installs on first run (bootstrap pattern in lazy_init.lua)

### Adding a Plugin

Create a file in `lua/plugins/` returning the plugin spec:

```lua
-- lua/plugins/example.lua
return {
  "owner/plugin-name",
  opts = { ... },
}
```

### Syncing Plugins

Open Neovim and run `:Lazy sync` to install/update plugins according to specs.

## LSP Configuration

Uses Neovim 0.11+ native LSP (no nvim-lspconfig plugin required).

### Adding an LSP Server

1. Create a config file in `lsp/<server_name>.lua`:

```lua
-- lsp/rust_analyzer.lua
return {
  cmd = { 'rust-analyzer' },
  filetypes = { 'rust' },
  root_markers = { 'Cargo.toml', '.git' },
}
```

2. Enable it in `lua/lsp_setup.lua`:

```lua
vim.lsp.enable('rust_analyzer')
```

### LSP Keymaps

| Key | Action |
|-----|--------|
| `gd` | Go to definition |
| `gr` | Find references |
| `K` | Hover documentation |
| `<leader>ca` | Code actions |
| `<leader>rn` | Rename symbol |
| `<leader>f` | Format buffer |
| `[d` / `]d` | Previous/next diagnostic |
