-- VS Code-style preview tab for files opened from the file tree: the next file opened
-- from the tree replaces it, unless it was pinned (opened again, double-clicked, edited).
local M = {}

local preview -- bufnr of the preview buffer

function M.is_preview(buf)
  return preview ~= nil and buf == preview
end

-- The preview buffer if it's still an open tab.
function M.current()
  if preview and vim.api.nvim_buf_is_valid(preview) and vim.bo[preview].buflisted then return preview end
end

function M.pin(buf)
  if buf == preview then
    preview = nil
    vim.cmd.redrawtabline()
  end
end

local function find_buf(path)
  for _, b in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_get_name(b) == path then return b end
  end
end

-- Show `path` in `win` as the preview and close the previous preview. A file already
-- open as a normal tab is just shown.
function M.open(path, win)
  path = vim.fs.normalize(vim.fn.fnamemodify(path, ":p"))
  local existing = find_buf(path)
  if existing and (existing == preview or vim.bo[existing].buflisted) then
    vim.api.nvim_win_set_buf(win, existing)
    return existing
  end
  local old = preview
  vim.api.nvim_win_call(win, function() vim.cmd.edit(vim.fn.fnameescape(path)) end)
  preview = vim.api.nvim_win_get_buf(win)
  if old and old ~= preview and vim.api.nvim_buf_is_valid(old) and vim.bo[old].buflisted
    and not vim.bo[old].modified and #vim.fn.win_findbuf(old) == 0 then
    vim.cmd.bdelete(old)
  end
  vim.cmd.redrawtabline()
  return preview
end

-- Enter in the tree: preview the file. On the file `win` already shows, pin it and
-- return true so the caller moves into it (Enter twice = double-click).
function M.tree_open(path, win)
  local buf = find_buf(vim.fs.normalize(vim.fn.fnamemodify(path, ":p")))
  if buf and vim.api.nvim_win_get_buf(win) == buf then
    M.pin(buf)
    return true
  end
  M.open(path, win)
  return false
end

function M.open_pinned(path, win)
  M.pin(M.open(path, win))
end

local group = vim.api.nvim_create_augroup("tree_preview", {})
-- Your edits leave the buffer 'modified'; a reload from disk (Claude's edits) doesn't.
-- (BufModifiedSet would fit, but it doesn't fire for ordinary edits.)
vim.api.nvim_create_autocmd({ "TextChanged", "TextChangedI" }, {
  group = group,
  callback = function(ev)
    if vim.bo[ev.buf].modified then M.pin(ev.buf) end
  end,
})
vim.api.nvim_create_autocmd({ "BufDelete", "BufWipeout" }, {
  group = group,
  callback = function(ev)
    if ev.buf == preview then preview = nil end
  end,
})

return M
