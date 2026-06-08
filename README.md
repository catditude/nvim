# nvim config

Minimal Neovim config built on lazy.nvim. Neovim 0.11+ required (native LSP, `vim.snippet`, `vim.uv`).

Custom colorscheme: **1989** — dark theme with pastels (lavender, pink, mint, light blue) on `#1c1c1c` background.

## Structure

```
init.lua                → Options, leader key, colorscheme, requires
lua/lazy_init.lua       → lazy.nvim bootstrap
lua/lsp_setup.lua       → LSP servers, keymaps, document highlight, inlay hints
lua/file_watcher.lua    → Auto-reload buffers on external file changes (libuv polling)
lua/plugins/*.lua       → One file per plugin
lua/lsp/*.lua           → LSP server configs (native 0.11 format)
colors/1989.lua         → Colorscheme
```

## Keymaps

Leader is **Space**.

### General

| Key | What it does |
|-----|-------------|
| `Esc` | Clear search highlight |
| `y` | Yank to system clipboard |
| `<leader>p` | Paste from system clipboard |
| `<C-h/j/k/l>` | Navigate between nvim splits and tmux panes |
| `<C-\>` | Previous tmux pane |

### Finding stuff (Telescope)

| Key | What it does |
|-----|-------------|
| `<leader>ff` | Find files |
| `<leader>fg` | Live grep |
| `<leader>fb` | Buffers |
| `<leader>fh` | Help tags |
| `<leader>fk` | Keymaps |
| `<leader>fd` | Diagnostics |
| `<leader>fs` | Document symbols |
| `<leader>fS` | Workspace symbols (global) |

### LSP

| Key | What it does |
|-----|-------------|
| `gd` | Go to definition |
| `gr` | References |
| `gy` | Type definition |
| `<leader>d` | Diagnostic float |
| `]d` / `[d` | Next / prev diagnostic |
| `<leader>ca` | Code action |
| `<leader>cr` | Rename symbol |
| `<leader>cf` | Format file |

### Git (gitsigns)

| Key | What it does |
|-----|-------------|
| `]c` / `[c` | Next / prev hunk |
| `<leader>hp` | Preview hunk |
| `<leader>hi` | Preview hunk inline |
| `<leader>hs` / `<leader>hr` | Stage / reset hunk (works in visual too) |
| `<leader>hS` / `<leader>hR` | Stage / reset entire buffer |
| `<leader>hb` | Blame line (full) |
| `<leader>hd` | Diff this |
| `<leader>hD` | Diff this vs previous commit |
| `<leader>hq` / `<leader>hQ` | Hunks to quickfix (buffer / all) |
| `<leader>tb` | Toggle line blame |
| `<leader>tw` | Toggle word diff |
| `ih` | Select hunk (text object) |

### Git (other)

| Key | What it does |
|-----|-------------|
| `<leader>lg` | Open lazygit |
| `<leader>gd` | Diffview (working tree) |
| `<leader>gh` | File history (current file) |
| `q` | Close diffview |

### Buffers

| Key | What it does |
|-----|-------------|
| `S-h` | Previous buffer |
| `S-l` | Next buffer |
| `<leader>bd` | Close buffer |
| `<leader>bo` | Close other buffers |
| `<leader>br` | Close buffers to the right |
| `<leader>bl` | Close buffers to the left |
| `<leader>ba` | Close all buffers |

### Navigation

| Key | What it does |
|-----|-------------|
| `-` | Open parent directory (oil.nvim) |
| `s` | Flash jump |
| `]t` / `[t` | Next / prev todo comment |
| `<leader>?` | Which-key (buffer keymaps) |

## Plugins

- **oil.nvim** — edit filesystem like a buffer, shows hidden files, git status in sign column (via oil-git-status.nvim)
- **telescope.nvim** — fuzzy finder with fzf-native sorter
- **flash.nvim** — jump anywhere with `s`, pink highlight labels
- **gitsigns.nvim** — gutter signs, inline hunk previews, staging, blame, word diff
- **diffview.nvim** — side-by-side diffs with tree file panel, treesitter highlighting in diff buffers, full file content (no folding)
- **lazygit.nvim** — full lazygit TUI inside nvim (uses delta as diff pager)
- **which-key.nvim** — keymap hints popup
- **lualine.nvim** — statusline: mode, branch, dirty indicator (`*`), ahead/behind arrows, diff stats, diagnostics, shortened path, filename, navic breadcrumbs, filetype, position. Tabline shows open buffers (with index + name) and tab pages
- **nvim-navic** — LSP breadcrumbs in statusline (e.g. `MyStruct > impl Display > fmt`)
- **nvim-cmp** — completion from LSP, buffer, and path sources. `<Tab>` to confirm, ghost text preview, keyword length 2
- **treesitter** — syntax highlighting via `vim.treesitter.start()` on all filetypes
- **treesitter-context** — sticky scope header (1 line max) showing enclosing function/struct/class
- **mason.nvim** — LSP/tool installer
- **snacks.nvim** — startup dashboard with cute cat header, quick-access keys (find files, grep, restore session), and git status
- **blink.indent** — fast indent guides with scope highlighting, `ii`/`ai` textobjects for indent blocks
- **noice.nvim** — floating cmdline popup, enhanced messages, LSP doc borders (depends on nui.nvim)
- **todo-comments.nvim** — colorized TODO/FIXME/HACK/NOTE highlights with `]t`/`[t` navigation, `:TodoTelescope` search
- **render-markdown.nvim** — renders markdown inline in the buffer (headings, code blocks, checkboxes, tables, etc.)
- **mini.icons** — icon provider
- **auto-session** — auto save/restore sessions per directory
- **vim-tmux-navigator** — seamless split/pane navigation with tmux

## LSP Servers

All use Neovim 0.11 native LSP (no nvim-lspconfig). Configs in `lua/lsp/`, registered in `lua/lsp_setup.lua`. Inlay hints enabled globally.

| Server | Language | Notes |
|--------|----------|-------|
| **rust-analyzer** | Rust | Uses clippy for diagnostics |
| **basedpyright** | Python | Inlay hints for variable types, return types, argument names, generics |
| **ruff** | Python | Linting + formatting, hover disabled (basedpyright handles it) |
| **lua_ls** | Lua | Neovim runtime in workspace library, recognizes `vim` global |
| **vtsls** | TypeScript / JavaScript | VSCode tsserver wrapper; inlay hints for params, types, returns. Handles `.ts`/`.tsx`/`.js`/`.jsx` |
| **eslint** | TypeScript / JavaScript | Lint diagnostics + `--fix` code actions; self-deactivates without an eslint config |

### Adding a new LSP server

1. `:MasonInstall <server_name>`
2. Create `lua/lsp/<server_name>.lua` returning `{ cmd, filetypes, root_markers, settings }`
3. Add to `lua/lsp_setup.lua`:
   ```lua
   vim.lsp.config('server_name', require('lsp.server_name'))
   vim.lsp.enable('server_name')
   ```
   Both lines are required — `vim.lsp.enable` alone won't pick up configs from `lua/lsp/`.

## LSP Extras

- **Document highlight** — cursor hold highlights all references to the symbol under cursor, clears on move
- **Ruff hover disabled** — ruff's hover is turned off so basedpyright is the sole hover provider for Python
- **nvim-cmp capabilities** — injected into all LSP servers via `vim.lsp.config('*')`

## Custom Features

### File watcher (`lua/file_watcher.lua`)
Polls open files every 1 second with `vim.uv.new_fs_poll()` and runs `checktime` when changes are detected. Useful when external tools (formatters, git operations) modify files outside nvim.

### Git ahead/behind (`lua/git_ahead_behind.lua`)
Periodically queries `git rev-list --left-right --count HEAD...@{upstream}` to populate `vim.g._git_ahead` and `vim.g._git_behind` for the lualine statusline. Refreshes every 30 seconds, on focus gain, and after buffer writes.

### 1989 colorscheme (`colors/1989.lua`)
Hand-rolled dark theme. Palette: lavender (`#dfafff`), pink (`#f075a0`), mint (`#9EB294`), light blue (`#A2CFFE`), light purple/rose (`#F0C4C8`), light yellow (`#ffffaf`). Includes highlight groups for diagnostics, gitsigns, treesitter-context, navic breadcrumbs, inlay hints, diffs, indent guides (blink.indent), dashboard (snacks.nvim), noice.nvim cmdline, and language-specific syntax (Ruby, JS, YAML, CSS, Markdown, HTML).

## Settings

- Relative line numbers
- Cursor line highlighted
- `scrolloff=999` (cursor stays centered)
- `updatetime=300` (faster CursorHold for document highlight)
- Histogram diff algorithm with `linematch:200`

## External Dependencies

- **delta** — terminal diff pager for git and lazygit
- **fzf** — for telescope-fzf-native
- **lazygit** — git TUI
- **tmux** — for vim-tmux-navigator
