-- Open the snacks file tree by itself on the first file you open after startup or a
-- session restore. After that it stays however <leader>e leaves it. Also keeps the tree
-- out of the way of :q and session files.
local M = {}
local pending = true
local reopen = false

local function is_tree(win)
  local ft = vim.bo[vim.api.nvim_win_get_buf(win)].filetype
  return ft == "snacks_layout_box" or ft:find("^snacks_picker") ~= nil
end

-- picker:close() closes its windows on a later tick, too late for a :q or a session
-- save already in progress, so close them here as well.
local function close_now(all_tabs)
  local filter = { source = "explorer" }
  if all_tabs then filter.tab = false end
  local pickers = Snacks.picker.get(filter)
  if #pickers == 0 then return false end
  for _, p in ipairs(pickers) do p:close() end
  for _, tab in ipairs(all_tabs and vim.api.nvim_list_tabpages() or { 0 }) do
    for _, w in ipairs(vim.api.nvim_tabpage_list_wins(tab)) do
      if is_tree(w) then pcall(vim.api.nvim_win_close, w, true) end
    end
  end
  return true
end

local function try_open()
  if not pending then return end
  local buf, win = vim.api.nvim_get_current_buf(), vim.api.nvim_get_current_win()
  local path = vim.api.nvim_buf_get_name(buf)
  if vim.bo[buf].buftype ~= "" or path == "" or vim.wo[win].diff
    or vim.api.nvim_win_get_config(win).relative ~= "" or vim.o.columns < 120 then
    return
  end
  -- nvim as someone else's editor: git commit/rebase messages, Claude's prompt editor
  -- (a temp file outside the cwd).
  if path:find("/.git/", 1, true) or not vim.fs.relpath(vim.fn.getcwd(), path) then return end
  pending = false
  if Snacks.picker.get({ source = "explorer" })[1] then return end
  Snacks.explorer({ focus = false })
end

-- auto-session hooks (lua/plugins/auto-session.lua). Its own cleanup of non-file windows
-- only runs for the save on exit; a manual save would store the tree as an empty window.
function M.before_save()
  reopen = close_now(true)
end

function M.after_save()
  if reopen and vim.v.exiting == vim.NIL then Snacks.explorer({ focus = false }) end
  reopen = false
end

local group = vim.api.nvim_create_augroup("explorer_auto", {})
vim.api.nvim_create_autocmd("VimEnter", { group = group, callback = function() vim.schedule(try_open) end })
vim.api.nvim_create_autocmd("BufEnter", {
  group = group,
  callback = function()
    if vim.v.vim_did_enter == 1 then vim.schedule(try_open) end
  end,
})
vim.api.nvim_create_autocmd("SessionLoadPost", {
  group = group,
  callback = function()
    pending = true
    vim.schedule(try_open)
  end,
})

-- :q on the last file window would otherwise leave the tab showing only the tree.
vim.api.nvim_create_autocmd("QuitPre", {
  group = group,
  callback = function()
    local cur = vim.api.nvim_get_current_win()
    if vim.api.nvim_win_get_config(cur).relative ~= "" then return end
    for _, w in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
      if w ~= cur and vim.api.nvim_win_get_config(w).relative == "" and not is_tree(w) then return end
    end
    close_now(false)
  end,
})

return M
