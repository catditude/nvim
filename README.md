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

**Excluded dirs:** find-files and live-grep skip Brazil/CDK build noise and Python deps (`env/`, `build/`, `release-info/`, `dist/`, `cdk.out/`, `node_modules/`, `site-packages/`, versioned `X.Y.Z/lib/` installs). These are dir-name patterns, so they match at any depth: a source dir literally named `build`/`env`/`dist` would also be skipped. This is not Telescope config: the excludes live in `~/workplace/.ignore`, which both `rg` (grep) and `fd` (find-files) read. Brazil workspace roots are not git repos, so grep there has no `.gitignore` to obey, but `rg`/`fd` walk up to a parent `.ignore` regardless of git boundaries, so one file at the workspace container covers every package. To add or change an exclude, edit that file (gitignore syntax; use a leading `**/` for patterns with a mid-path `/`).

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
| `<leader>gd` | Diffview: uncommitted work (staged + unstaged), current repo |
| `<leader>gu` | Diffview: uncommitted work, all packages (pick one or all) |
| `<leader>gQ` | Uncommitted changed files across all packages to quickfix |
| `<leader>gF` | Find files, scoped to uncommitted files (all packages) |
| `<leader>gG` | Live grep, scoped to uncommitted files (all packages) |
| `<leader>gh` | File history (current file) |
| `q` | Close diffview |

The uncommitted family (`gu`/`gQ`/`gF`/`gG`) are the working-tree twins of the committed
review commands (`gc`/`gq`/`gf`/`gg`): same `lua/review.lua` multi-package machinery
("All packages" first, one tabpage per package), diffed vs HEAD (untracked files
included) instead of `upstream...HEAD`. Capital letter = uncommitted.

### Code review (`lua/review.lua`)

For reviewing committed work (an agent's output, a CR) rather than unstaged edits.
Baseline is `<base>...HEAD`, i.e. what a CR shows, not the index.

Multi-repo aware: in a Brazil workspace each package under `src/` is its own repo
on its own branch, and the workspace root is not a repo at all.

**Base resolution** (per package, in order): the branch's own `@{upstream}` if set,
else `origin/<target>` if that ref exists, else `origin/HEAD`. The target defaults to
`release-3.x`; override per session with `:lua vim.g.review_target = "mainline"`. The
configured target is tried before `origin/HEAD` because feature branches often have no
upstream and `origin/HEAD` tends to point at mainline or a Yocto version branch
(scarthgap), not the release branch a CR actually targets.

| Key | What it does |
|-----|-------------|
| `<leader>gc` | Review CR: `<CR>` opens all changed packages, or pick one |
| `<leader>gq` | Changed files across all packages to quickfix |
| `<leader>gb` | Toggle gitsigns base: index / per-repo fork point |
| `<leader>gf` | Find files, scoped to changed files (all packages) |
| `<leader>gg` | Live grep, scoped to changed files (all packages) |
| `]q` / `[q` | Next / prev quickfix entry |

`<leader>gc` lists changed packages with "All packages" first, so `<CR>` reviews the
whole CR; each package opens in its own tabpage (`gt` / `gT` to switch). With one
changed package it skips the menu. It works from any buffer, including the dashboard,
because it scans the workspace rather than the current buffer's repo. `--imply-local`
keeps LSP, diagnostics and `gd`/`gr` working on the HEAD side.

`<leader>gb` caveat: files **added** on the branch show no gutter signs. Gitsigns diffs
a buffer against a version of that same file, and with no blob at the base revision it
falls back to the buffer's own content (empty diff, not "all added"). Diffview diffs
trees, so the `<leader>gc` diffview lists added and deleted files correctly and is the
authoritative view; treat `<leader>gb` as a reading aid for modified files.

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
- **diffview.nvim** — adaptive diff layout via `lua/diff_layout.lua`: side-by-side when the window is wide (`>= 210` cols, e.g. a zoomed pane), else stacked (top/bottom). Re-evaluated on each open. Tree file panel (30 cols), treesitter highlighting in diff buffers, full file content (no folding). `<leader>b` toggles the file panel to reclaim width in a narrow pane
- **lazygit.nvim** — full lazygit TUI inside nvim (uses delta as diff pager)
- **which-key.nvim** — keymap hints popup
- **lualine.nvim** — statusline: mode, branch, dirty indicator (`*`), ahead/behind arrows, diff stats, diagnostics, shortened path, filename, navic breadcrumbs, filetype, position. Tabline shows open buffers (with index + name) and tab pages
- **aerial.nvim** — code outline sidebar (left panel). Toggle with `<leader>o`, navigate symbols with `{`/`}`. Starts at collapse level 1, closes on selection. Uses LSP with treesitter fallback
- **nvim-navic** — LSP breadcrumbs in statusline (e.g. `MyStruct > impl Display > fmt`)
- **nvim-cmp** — completion from LSP, buffer, and path sources. `<Tab>` to confirm, ghost text preview, keyword length 2
- **treesitter** — syntax highlighting via `vim.treesitter.start()` on all filetypes
- **treesitter-context** — sticky scope header (1 line max) showing enclosing function/struct/class
- **mason.nvim** — LSP/tool installer; **mason-tool-installer** auto-installs `ensure_installed` tools on startup (bash-language-server, shellcheck, shfmt)
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
| **jsonls** | JSON | Validation, formatting, schema support (Claude Code settings schema configured) |
| **vtsls** | TypeScript / JavaScript | VSCode tsserver wrapper; inlay hints for params, types, returns. Handles `.ts`/`.tsx`/`.js`/`.jsx` |
| **eslint** | TypeScript / JavaScript | Lint diagnostics + `--fix` code actions; self-deactivates without an eslint config |
| **bashls** | Bash / sh | Completion + hover; delegates diagnostics to `shellcheck` and formatting to `shfmt` (both installed via Mason) |

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
Periodically queries `git rev-list --left-right --count HEAD...@{upstream}` to populate `vim.g._git_ahead` and `vim.g._git_behind` for the lualine statusline. Refreshes every 30 seconds, on focus gain, after buffer writes, and on `BufEnter`.

The repo is resolved from the current buffer (via `review.repo_root()`), not from nvim's cwd. In a multi-repo workspace the cwd is often not a git repo at all, and even when it is, it's the wrong repo for the buffer you're looking at.

### Code review (`lua/review.lua`)
Review helpers for workspaces holding several git repos (Brazil: one repo per package under `src/`, workspace root not a repo).

Key ideas:
- **Baseline is `upstream...HEAD`, not the index.** Committed work is invisible to index-relative tooling, which is most of it by default.
- **Repos resolve per buffer.** `repo_root()` uses `vim.fs.root` (no subprocess, runs on every `BufEnter`); `workspace_repos()` anchors on `.brazil` rather than searching upward for `src`, because packages commonly contain their own `src/`.
- **Gitsigns' base is applied per buffer, not globally.** Git objects are repo-scoped, so a merge-base SHA from one package is unresolvable in another and gitsigns would silently show no signs. Applied via gitsigns' `on_attach`, deferred with `vim.schedule` since the buffer's cache entry doesn't exist yet at attach time.
- **`merge_base()` exists separately from `review_range()`.** `git diff` accepts `A...B`; `git show <rev>:<path>` (how gitsigns fetches its reference) rejects a range outright, so it needs the single fork-point SHA.
- **Submodule gitlinks are filtered from file lists.** `git diff --name-only` reports submodule pointer bumps as changed paths, but they're directories, not openable files.

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
