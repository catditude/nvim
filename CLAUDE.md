# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Instructions

**Always fetch the latest documentation** before making changes. Neovim and plugin APIs evolve frequently. Use context7 or web search to retrieve up-to-date docs for:
- Neovim APIs (vim.lsp, vim.api, etc.)
- Plugin configuration (lazy.nvim, nvim-cmp, treesitter, etc.)
- LSP server settings (rust-analyzer, pyright, lua_ls, etc.)

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

**Always check the plugin's GitHub README** for the recommended lazy.nvim installation spec before writing config.

Create a file in `lua/plugins/` returning the plugin spec:

```lua
-- lua/plugins/example.lua
return {
  "owner/plugin-name",
  opts = { ... },
}
```

**Keep specs minimal.** Don't add `lazy = true` or `cmd` when `keys` already handles lazy-loading.

### Syncing Plugins

Open Neovim and run `:Lazy sync` to install/update plugins according to specs.

### Adding a Custom Feature (non-plugin)

Create a Lua module in `lua/` and load it via `require()` in `init.lua`. See `lua/file_watcher.lua` as an example.

### Installed Plugins

- **oil.nvim** — File explorer (edit filesystem like a buffer), `-` to open
- **oil-git-status.nvim** — Git status icons in oil's sign column (modified, untracked, staged, etc.)
- **telescope.nvim** — Fuzzy finder, `<leader>ff` files, `<leader>fg` grep, `<leader>fb` buffers, `<leader>fh` help tags, `<leader>fk` keymaps, `<leader>fs` git status
- **flash.nvim** — Quick navigation/motions, `s` to jump
- **gitsigns.nvim** — Git signs in the gutter, `<leader>hp` preview hunk, `<leader>hb` blame line, `<leader>hs/hr` stage/reset hunk, `]c`/`[c` navigate hunks, `<leader>tb` toggle line blame, `ih` hunk text object
- **which-key.nvim** — Keybinding popup hints, `<leader>?` for buffer-local keymaps
- **lualine.nvim** — Statusline (mode, branch, diff, diagnostics, filename, filetype, cursor position)
- **mason.nvim** — LSP/tool installer
- **mini.icons** — Icon provider, mocks `nvim-web-devicons` API for plugin compatibility
- **treesitter** — Syntax highlighting and parsing (on `main` branch; uses `vim.treesitter.start()`, not `nvim-treesitter.configs`)
- **nvim-cmp** — Autocompletion (LSP, buffer, path sources), `<Tab>` to confirm, ghost text preview
- **diffview.nvim** — Side-by-side diff viewer with treesitter syntax highlighting, `<leader>gd` diff view, `<leader>gh` file history
- **lazygit.nvim** — Full lazygit TUI inside Neovim, `<leader>lg` to open. Uses delta as diff pager (configured in `~/.config/lazygit/config.yml`)
- **auto-session** — Automatic session save/restore per directory
- **vim-tmux-navigator** — Seamless `<C-h/j/k/l>` navigation between Neovim splits and tmux panes, `<C-\>` for previous

## LSP Configuration

Uses Neovim 0.11+ native LSP (no nvim-lspconfig plugin required).

**Important: Two-step registration.** Configs live in `lua/lsp/` (Lua require path), but `vim.lsp.enable()` only searches `lsp/` on the runtimepath (e.g. `~/.config/nvim/lsp/`). Since our configs are in `lua/lsp/`, you must explicitly register them with `vim.lsp.config()` using `require()` before calling `vim.lsp.enable()`. Omitting the `vim.lsp.config()` call means your config file is silently ignored — the server may still start using Neovim's built-in defaults (if one exists), but without your custom settings.

Features enabled:
- **Inlay hints** — Type annotations shown inline (auto-enabled on attach)
- **basedpyright** — Python type checking, completions, diagnostics, and inlay hints (pyright fork with extra features)
- **Clippy** — rust-analyzer uses clippy instead of cargo check for diagnostics
- **cmp capabilities** — `vim.lsp.config('*')` injects nvim-cmp capabilities into all servers

### Adding an LSP Server

1. Install the server binary via Mason (`:MasonInstall <server_name>`)

2. Create a config file in `lua/lsp/<server_name>.lua`:

```lua
-- lua/lsp/rust_analyzer.lua
return {
  cmd = { 'rust-analyzer' },
  filetypes = { 'rust' },
  root_markers = { 'Cargo.toml', '.git' },
}
```

3. Register and enable it in `lua/lsp_setup.lua` (both lines required):

```lua
vim.lsp.config('rust_analyzer', require('lsp.rust_analyzer'))
vim.lsp.enable('rust_analyzer')
```

### LSP Keymaps

| Key | Action |
|-----|--------|
| `gd` | Go to definition |
| `gr` | Find references |

## External Dependencies

- **delta** — Terminal diff pager used by git and lazygit. Configured in `~/.gitconfig` under `[delta]` with 1989-matching colors (diff backgrounds, line number colors, hunk header styling). Syntax highlighting uses delta's own syntect engine, not Neovim treesitter.
