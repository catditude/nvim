# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Instructions

**Always fetch the latest documentation** before making changes. Neovim and plugin APIs evolve frequently. Use context7 or web search to retrieve up-to-date docs for:
- Neovim APIs (vim.lsp, vim.api, etc.)
- Plugin configuration (lazy.nvim, nvim-cmp, treesitter, etc.)
- LSP server settings (rust-analyzer, lua_ls, etc.)

**After every change, check if CLAUDE.md needs updating.** If you add a plugin, change keymaps, modify the architecture, or alter LSP config, update the relevant sections of this file to keep it accurate.

## Overview

This is a Neovim configuration using **lazy.nvim** as the plugin manager. The configuration is minimal and modular.

**Leader key:** Space (`vim.g.mapleader = " "`) — set in `init.lua` before plugins load

## Architecture

**File organization:** All custom Lua modules go in `lua/`. Only Neovim-required paths (`init.lua`, `colors/`) stay at root.

```
init.lua              → Entry point, loads lazy_init, lsp_setup, and file_watcher
lua/lazy_init.lua     → Bootstraps lazy.nvim, imports plugins from lua/plugins/
lua/lsp_setup.lua     → Native LSP configuration (enables servers, keymaps)
lua/file_watcher.lua  → Auto-reloads buffers when files change externally (libuv polling)
lua/plugins/*.lua     → Plugin specifications (one file per plugin or category)
lua/lsp/*.lua         → LSP server configs (Neovim 0.11 native format)
colors/*.lua          → Colorscheme definitions
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

### Installed Plugins

- **oil.nvim** — File explorer (edit filesystem like a buffer), `-` to open
- **telescope.nvim** — Fuzzy finder, `<leader>ff` files, `<leader>fg` grep, `<leader>fb` buffers, `<leader>fh` help tags, `<leader>fk` keymaps
- **flash.nvim** — Quick navigation/motions, `s` to jump
- **gitsigns.nvim** — Git signs in the gutter (added/changed/deleted lines)
- **which-key.nvim** — Keybinding popup hints, `<leader>?` for buffer-local keymaps
- **lualine.nvim** — Statusline (mode, branch, diff, diagnostics, filename, filetype, cursor position)
- **mason.nvim** — LSP/tool installer
- **treesitter** — Syntax highlighting and parsing
- **lazygit.nvim** — Full lazygit TUI inside Neovim, `<leader>lg` to open
- **auto-session** — Automatic session save/restore per directory

## LSP Configuration

Uses Neovim 0.11+ native LSP (no nvim-lspconfig plugin required).

Features enabled:
- **Inlay hints** — Type annotations shown inline (auto-enabled on attach)
- **Clippy** — rust-analyzer uses clippy instead of cargo check for diagnostics

### Adding an LSP Server

1. Create a config file in `lua/lsp/<server_name>.lua`:

```lua
-- lua/lsp/rust_analyzer.lua
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
