-- Code review helpers for multi-repo workspaces (e.g. Brazil: many git repos under src/).
--
-- The problem: reviewing agent-written code means reviewing *commits*, not the
-- working tree, and a Brazil workspace root is not a git repo. Each package
-- under src/ is its own repo on its own branch. Built-in git tooling assumes one
-- repo resolved from cwd, so it either errors or silently reports the wrong one.
--
-- Everything here resolves repos explicitly and treats "the review diff" as
-- upstream...HEAD rather than the index.

local M = {}

-- Cache repo root per directory. Buffers churn far more often than roots change.
local root_cache = {}

local function git(root, args)
  local cmd = { "git", "-C", root }
  vim.list_extend(cmd, args)
  local out = vim.system(cmd, { text = true }):wait()
  if out.code ~= 0 then return nil end
  return (out.stdout or ""):gsub("%s+$", "")
end

--- Git top-level for a path, or nil. Resolves from the buffer's directory, not cwd.
--- Uses vim.fs.root (pure filesystem walk) rather than shelling out: this runs on
--- every BufEnter, and a subprocess per buffer switch is not free. Nested repos
--- resolve to the innermost .git, which is what git itself would do.
--- @param path string?
--- @return string?
function M.repo_root(path)
  path = path or vim.api.nvim_buf_get_name(0)
  -- Plugin buffers name themselves with a URI (oil:///real/path, diffview://...).
  -- Strip the scheme so browsing a directory in oil still resolves its repo;
  -- without this the name isn't a real path, so we'd fall through to cwd and
  -- silently answer for the wrong repo (or none, at a workspace root).
  path = path:gsub("^%w[%w+.-]*://+", "/")
  local dir = (path ~= "" and vim.fn.isdirectory(path) == 0) and vim.fs.dirname(path) or path
  if dir == "" or vim.fn.isdirectory(dir) == 0 then dir = vim.uv.cwd() end
  if root_cache[dir] ~= nil then
    return root_cache[dir] or nil
  end
  -- Matches both a .git directory and the .git *file* used by submodules/worktrees.
  local root = vim.fs.root(dir, ".git")
  root_cache[dir] = root or false
  return root
end

--- The branch a CR targets, when a package's git branch has no upstream to infer it.
--- Override per session with `vim.g.review_target` (e.g. for a mainline CR).
--- @return string
local function target_branch()
  return vim.g.review_target or "release-3.x"
end

--- Base ref to diff a package against.
---
--- Resolution order, because in a Brazil workspace neither signal alone is reliable:
---   1. the branch's own @{upstream}, if configured (most correct when present);
---   2. origin/<target_branch>, if that remote ref exists (the CR's destination);
---   3. origin/HEAD, the remote default.
--- @{upstream} is often unset on feature branches, and origin/HEAD frequently points
--- at mainline or a Yocto version branch (scarthgap) rather than the release branch a
--- CR actually targets, so the configured target is tried before that last fallback.
--- @param root string
--- @return string?
function M.upstream(root)
  local up = git(root, { "rev-parse", "--abbrev-ref", "--symbolic-full-name", "@{upstream}" })
  if up and up ~= "" then return up end

  local target = "origin/" .. target_branch()
  local sha = git(root, { "rev-parse", "--verify", "--quiet", target .. "^{commit}" })
  if sha and sha ~= "" then
    return target
  end

  local head = git(root, { "symbolic-ref", "--short", "refs/remotes/origin/HEAD" })
  return (head and head ~= "") and head or nil
end

--- The revision range a CR would show: everything on this branch since it forked
--- from upstream. Symmetric difference (...) so upstream commits you haven't
--- merged don't show up as your changes.
--- @param root string
--- @return string? range, string? err
function M.review_range(root)
  local up = M.upstream(root)
  if not up then
    return nil, "no upstream or origin/HEAD for " .. vim.fs.basename(root)
  end
  return up .. "...HEAD"
end

--- The single commit where this branch forked from upstream.
---
--- Needed because not every consumer accepts a range. `git diff` understands
--- `A...B`, but `git show <rev>:<path>` (how gitsigns fetches its reference blob)
--- rejects it outright: "Invalid symmetric difference expression". Since `A...B`
--- means "since the merge base", this SHA is the equivalent single revision.
--- @param root string
--- @return string? sha, string? err
function M.merge_base(root)
  local up = M.upstream(root)
  if not up then
    return nil, "no upstream or origin/HEAD for " .. vim.fs.basename(root)
  end
  local sha = git(root, { "merge-base", "HEAD", up })
  if not sha or sha == "" then
    return nil, "no merge-base with " .. up
  end
  return sha
end

--- Sibling package repos in a Brazil workspace, or just the current repo elsewhere.
---
--- Anchors on .brazil, NOT on an upward search for "src": packages frequently
--- contain their own src/ directory (any Python package does), so searching
--- upward for "src" stops inside the package and finds nothing.
--- @param from string?
--- @return string[]
function M.workspace_repos(from)
  local start = from or vim.api.nvim_buf_get_name(0)
  if start == "" then start = vim.uv.cwd() end
  local ws = vim.fs.find(".brazil", { path = start, upward = true, type = "directory" })[1]
  local src = ws and (vim.fs.dirname(ws) .. "/src")

  if not src or vim.fn.isdirectory(src) == 0 then
    local root = M.repo_root(start)
    return root and { root } or {}
  end

  local repos = {}
  for name, kind in vim.fs.dir(src) do
    if kind == "directory" then
      local p = src .. "/" .. name
      -- .git is a file in worktrees/submodules, a directory otherwise.
      if vim.uv.fs_stat(p .. "/.git") then table.insert(repos, p) end
    end
  end
  table.sort(repos)
  return repos
end

--- Files changed in a repo's review range, as absolute paths.
---
--- Skips anything that isn't a readable regular file. git reports submodule
--- pointer bumps (gitlinks) as modified paths, but they're directories: real
--- review content, yet not openable in a buffer. YoctoMetaTegraMatrix bumping
--- its YoctoMetaTegraARS submodule is exactly this case.
--- @param root string
--- @return string[]
function M.changed_files(root)
  local range = M.review_range(root)
  if not range then return {} end
  local out = git(root, { "diff", "--name-only", "--diff-filter=d", range })
  if not out or out == "" then return {} end

  local files = {}
  for _, rel in ipairs(vim.split(out, "\n", { trimempty = true })) do
    local abs = root .. "/" .. rel
    if vim.fn.filereadable(abs) == 1 then table.insert(files, abs) end
  end
  return files
end

--- Files with uncommitted changes in a repo (staged + unstaged vs HEAD, minus
--- deletions) plus untracked files, as absolute readable paths. Deletions are
--- dropped (nothing to open); untracked files are kept (they're part of the
--- uncommitted work, and git diff won't report them).
--- @param root string
--- @return string[]
function M.worktree_files(root)
  local files = {}
  for _, out in ipairs({
    (git(root, { "diff", "--name-only", "--diff-filter=d", "HEAD" }) or ""),
    (git(root, { "ls-files", "--others", "--exclude-standard" }) or ""),
  }) do
    if out ~= "" then
      for _, rel in ipairs(vim.split(out, "\n", { trimempty = true })) do
        local abs = root .. "/" .. rel
        if vim.fn.filereadable(abs) == 1 then table.insert(files, abs) end
      end
    end
  end
  return files
end

--- Per-repo change stats for the review range. Repos with no changes are omitted.
--- @return table[] { root, name, files, insertions, deletions }
function M.workspace_summary()
  local result = {}
  for _, root in ipairs(M.workspace_repos()) do
    local range = M.review_range(root)
    if range then
      local stat = git(root, { "diff", "--shortstat", range })
      if stat and stat ~= "" then
        table.insert(result, {
          root = root,
          name = vim.fs.basename(root),
          files = tonumber(stat:match("(%d+) files? changed")) or 0,
          insertions = tonumber(stat:match("(%d+) insertions?")) or 0,
          deletions = tonumber(stat:match("(%d+) deletions?")) or 0,
        })
      end
    end
  end
  return result
end

--- Per-repo stats for uncommitted work (staged + unstaged vs HEAD). Repos with no
--- changes are omitted. Untracked files count toward inclusion (git diff doesn't
--- report them), so a package with only new files still appears, matching what a
--- no-rev DiffviewOpen lists.
--- @return table[] { root, name, files, insertions, deletions }
function M.worktree_summary()
  local result = {}
  for _, root in ipairs(M.workspace_repos()) do
    local stat = git(root, { "diff", "--shortstat", "HEAD" })
    local untracked = git(root, { "ls-files", "--others", "--exclude-standard" })
    if (stat and stat ~= "") or (untracked and untracked ~= "") then
      table.insert(result, {
        root = root,
        name = vim.fs.basename(root),
        files = tonumber(stat and stat:match("(%d+) files? changed") or "") or 0,
        insertions = tonumber(stat and stat:match("(%d+) insertions?") or "") or 0,
        deletions = tonumber(stat and stat:match("(%d+) deletions?") or "") or 0,
      })
    end
  end
  return result
end

--- Open a Diffview for a repo's review range.
--- --imply-local points the HEAD side at real files on disk so LSP, diagnostics
--- and gd/gr keep working during review. Without it both sides are git blobs.
--- @param root string
function M.open_diff(root)
  local range, err = M.review_range(root)
  if not range then
    vim.notify(err, vim.log.levels.WARN)
    return
  end
  require("diff_layout").apply()
  vim.cmd(("DiffviewOpen -C%s %s --imply-local"):format(vim.fn.fnameescape(root), range))
end

--- Open a Diffview of a repo's uncommitted work. No rev, so it matches <leader>gd:
--- the file panel splits into unstaged "Changes" and "Staged changes", and hunks
--- can be staged in place.
--- @param root string
function M.worktree_open(root)
  require("diff_layout").apply()
  vim.cmd(("DiffviewOpen -C%s --imply-local"):format(vim.fn.fnameescape(root)))
end

--- Package picker shared by the review (upstream...HEAD) and uncommitted flows.
--- `summary` returns the changed-package list; `open_one(root)` opens one package.
--- "All packages" is first so <CR> covers everything (the common case); each
--- Diffview lives in its own tabpage, so opening several is fine. One changed
--- package skips the menu.
--- @param summary fun(): table[]
--- @param open_one fun(root: string)
--- @param prompt string
--- @param empty_msg string
local function pick(summary, open_one, prompt, empty_msg)
  local pkgs = summary()
  if #pkgs == 0 then
    vim.notify(empty_msg, vim.log.levels.INFO)
    return
  end
  if #pkgs == 1 then
    open_one(pkgs[1].root)
    return
  end

  local files, adds, dels = 0, 0, 0
  for _, p in ipairs(pkgs) do
    files, adds, dels = files + p.files, adds + p.insertions, dels + p.deletions
  end

  local items = { { root = "*", name = "All packages", files = files, insertions = adds, deletions = dels } }
  vim.list_extend(items, pkgs)

  vim.ui.select(items, {
    prompt = prompt,
    format_item = function(p)
      local label = p.root == "*" and ("All %d packages"):format(#pkgs) or p.name
      return ("%-36s %2d files  +%d/-%d"):format(label, p.files, p.insertions, p.deletions)
    end,
  }, function(choice)
    if not choice then return end
    if choice.root == "*" then
      for _, p in ipairs(pkgs) do
        if p.root ~= "*" then open_one(p.root) end
      end
    else
      open_one(choice.root)
    end
  end)
end

--- Pick a package to review (upstream...HEAD) from all changed packages.
function M.review_pick()
  pick(M.workspace_summary, M.open_diff, "Review package:", "no packages with changes vs upstream")
end

--- Like review_pick, but for uncommitted work (staged + unstaged vs HEAD), the
--- multi-package version of <leader>gd.
function M.worktree_pick()
  pick(M.worktree_summary, M.worktree_open, "Uncommitted package:", "no packages with uncommitted changes")
end

--- Quickfix list of every file from `files_fn` across every package. Gives one
--- linear walk (]q / [q) over the whole surface. Diffview has no multi-repo view.
--- @param files_fn fun(root: string): string[]
--- @param title string
--- @param empty_msg string
local function to_quickfix(files_fn, title, empty_msg)
  local items = {}
  for _, root in ipairs(M.workspace_repos()) do
    for _, file in ipairs(files_fn(root)) do
      table.insert(items, { filename = file, lnum = 1, col = 1, text = vim.fs.basename(root) })
    end
  end
  if #items == 0 then
    vim.notify(empty_msg, vim.log.levels.INFO)
    return
  end
  vim.fn.setqflist({}, " ", { title = title, items = items })
  vim.cmd("copen")
end

--- Every file from `files_fn` across the workspace, flattened, for Telescope scoping.
--- @param files_fn fun(root: string): string[]
--- @return string[]
local function collect(files_fn)
  local files = {}
  for _, root in ipairs(M.workspace_repos()) do
    vim.list_extend(files, files_fn(root))
  end
  return files
end

--- Telescope `builtin` scoped to the files from `files_fn`. find_files treats each
--- path as its own search root; live_grep restricts the grep to them.
--- @param builtin string
--- @param files_fn fun(root: string): string[]
--- @param title string
--- @param empty_msg string
local function telescope_over(builtin, files_fn, title, empty_msg)
  local files = collect(files_fn)
  if #files == 0 then
    vim.notify(empty_msg, vim.log.levels.INFO)
    return
  end
  require("telescope.builtin")[builtin]({
    prompt_title = title,
    search_dirs = files,
  })
end

-- Review (upstream...HEAD) and uncommitted (vs HEAD) variants of the file-scoped
-- helpers. Each pair differs only in which per-repo file lister it passes.

function M.changed_to_quickfix()
  to_quickfix(M.changed_files, "Review: changed files", "no changed files vs upstream")
end

function M.worktree_to_quickfix()
  to_quickfix(M.worktree_files, "Uncommitted: changed files", "no uncommitted changed files")
end

function M.find_changed()
  telescope_over("find_files", M.changed_files, "Changed files (review)", "no changed files vs upstream")
end

function M.worktree_find()
  telescope_over("find_files", M.worktree_files, "Uncommitted files", "no uncommitted changed files")
end

function M.grep_changed()
  telescope_over("live_grep", M.changed_files, "Grep changed files (review)", "no changed files vs upstream")
end

function M.worktree_grep()
  telescope_over("live_grep", M.worktree_files, "Grep uncommitted files", "no uncommitted changed files")
end

-- "Review mode": gitsigns' gutter shows the review diff instead of unstaged work.
--
-- Gitsigns' default base is the index, which shows nothing once the agent's work is
-- committed. The obvious fix, change_base(sha, true), does NOT work across repos:
-- git objects are repo-scoped, so a merge-base SHA from package A is unresolvable
-- in package B ("could not get object info") and gitsigns silently attaches with no
-- signs at all. So resolve the base per buffer, in that buffer's own repo, and keep
-- an autocmd so buffers opened later get the same treatment.
local review_mode = false

--- Point one buffer's gitsigns base at its own repo's fork point.
---
--- Deferred because this is called from gitsigns' on_attach, where the buffer's
--- cache entry does not exist yet: a non-global change_base looks up that entry and
--- returns early if it's missing, so calling it inline is a silent no-op.
--- @param buf integer
function M.apply_base(buf)
  if not review_mode then return end
  if not vim.api.nvim_buf_is_valid(buf) or vim.bo[buf].buftype ~= "" then return end
  local root = M.repo_root(vim.api.nvim_buf_get_name(buf))
  if not root then return end
  -- Must be a single revision, not a range. See M.merge_base.
  local sha = M.merge_base(root)
  if not sha then return end
  vim.schedule(function()
    if not review_mode or not vim.api.nvim_buf_is_valid(buf) then return end
    vim.api.nvim_buf_call(buf, function()
      require("gitsigns").change_base(sha, false)
    end)
  end)
end

--- Toggle gitsigns' diff base between the index and each repo's fork point.
---
--- Known limitation: files ADDED on this branch show no signs. Gitsigns diffs a
--- buffer against a version of that same file, and for a path with no blob at the
--- base revision it falls back to the buffer's own content, so the diff is empty
--- rather than "all added". Diffview (<leader>gc) diffs trees and lists added and
--- deleted files correctly, so it stays the authoritative review view.
function M.toggle_base()
  local gs = require("gitsigns")

  if review_mode then
    review_mode = false
    gs.reset_base(true)
    vim.notify("gitsigns base: index")
    return
  end

  local root = M.repo_root()
  if not root then
    vim.notify("not in a git repo", vim.log.levels.WARN)
    return
  end
  local _, err = M.merge_base(root)
  if err then
    vim.notify(err, vim.log.levels.WARN)
    return
  end

  review_mode = true
  -- Buffers opened later are handled by gitsigns' on_attach, which calls
  -- M.apply_base (see lua/plugins/gitsigns.lua).
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if vim.bo[buf].buflisted then M.apply_base(buf) end
  end
  vim.notify("gitsigns base: review (per-repo fork point)")
end

--- @return boolean
function M.review_mode()
  return review_mode
end

return M
