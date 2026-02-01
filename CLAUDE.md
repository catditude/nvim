# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This is a Neovim configuration using **lazy.nvim** as the plugin manager. The configuration is minimal and modular.

## Architecture

```
init.lua              → Entry point, loads lua/lazy_init.lua
lua/lazy_init.lua     → Bootstraps lazy.nvim, imports plugins from lua/plugins/
lua/plugins/*.lua     → Plugin specifications (one file per plugin or category)
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
