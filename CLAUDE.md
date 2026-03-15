# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Instructions

**Always fetch the latest documentation** before making changes. Neovim and plugin APIs evolve frequently. Use context7 or web search to retrieve up-to-date docs for:
- Neovim APIs (vim.lsp, vim.api, etc.)
- Plugin configuration (lazy.nvim, nvim-cmp, treesitter, etc.)
- LSP server settings (rust-analyzer, pyright, lua_ls, etc.)

**After every change, update README.md** if you add a plugin, change keymaps, modify the architecture, or alter LSP config.

**See README.md** for the full list of plugins, keymaps, LSP servers, settings, and external dependencies.

## Overview

Neovim 0.11+ config using **lazy.nvim**. Minimal and modular.

**Leader key:** Space (`vim.g.mapleader = " "`) — set in `init.lua` before plugins load.

## Architecture

All custom Lua modules go in `lua/`. Only Neovim-required paths (`init.lua`, `colors/`) stay at root.

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

## How to Add a Plugin

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

Run `:Lazy sync` in Neovim to install.

## How to Add a Custom Feature (non-plugin)

Create a Lua module in `lua/` and load it via `require()` in `init.lua`. See `lua/file_watcher.lua` as an example.

## How to Add an LSP Server

1. Install via Mason: `:MasonInstall <server_name>`

2. Create `lua/lsp/<server_name>.lua`:

```lua
return {
  cmd = { 'rust-analyzer' },
  filetypes = { 'rust' },
  root_markers = { 'Cargo.toml', '.git' },
}
```

3. Register **and** enable in `lua/lsp_setup.lua` (both lines required):

```lua
vim.lsp.config('rust_analyzer', require('lsp.rust_analyzer'))
vim.lsp.enable('rust_analyzer')
```

### LSP Gotcha: Two-step Registration

Configs live in `lua/lsp/` (Lua require path), but `vim.lsp.enable()` only searches `lsp/` on the runtimepath (e.g. `~/.config/nvim/lsp/`). Since our configs are in `lua/lsp/`, you **must** call `vim.lsp.config()` with `require()` before `vim.lsp.enable()`. Omitting the `vim.lsp.config()` call means the config is silently ignored — the server may start with Neovim's built-in defaults instead.

## Colorscheme Conventions

All highlight groups — including plugin-specific ones — go in `colors/1989.lua`, not in plugin `config` callbacks. This keeps theming centralized.

Every hex color must be a named entry in the `colors` palette table at the top of the file. Never use raw hex literals in `hi()` calls.

## Neovim API (0.11+)

Use modern APIs — avoid deprecated ones:
- `vim.uv` not `vim.loop`
- `vim.diagnostic.jump({ count = N })` not `vim.diagnostic.goto_next/prev`
- libuv handles: always call both `:stop()` and `:close()` to avoid fd leaks
