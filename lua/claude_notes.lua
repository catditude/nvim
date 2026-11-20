-- Review notes for Claude: virtual-text notes on lines or ranges, sent to Claude as one
-- file (<cwd>/.claude/notes.md) through the claudecode.nvim /ide connection.
local M = {}

local ns = vim.api.nvim_create_namespace("claude_notes")
local group = vim.api.nvim_create_augroup("claude_notes", {})

-- Each note: path, text, row/end_row (0-based, inclusive), code (the noted lines as of
-- the last add/edit/write), buf/mark (nil while the file isn't loaded).
local notes = {}

local function attached(n)
  return n.mark and n.buf and vim.api.nvim_buf_is_loaded(n.buf)
end

local function sync(n)
  if not attached(n) then return end
  local pos = vim.api.nvim_buf_get_extmark_by_id(n.buf, ns, n.mark, { details = true })
  if pos[1] then
    n.row = pos[1]
    n.end_row = math.max(pos[1], pos[3].end_row or pos[1])
  end
end

local function snapshot(n)
  n.code = vim.api.nvim_buf_get_lines(n.buf, n.row, n.end_row + 1, false)
end

local function place(n, buf)
  local last = vim.api.nvim_buf_line_count(buf) - 1
  n.row = math.min(n.row, last)
  n.end_row = math.min(math.max(n.end_row, n.row), last)
  n.buf = buf
  n.mark = vim.api.nvim_buf_set_extmark(buf, ns, n.row, 0, {
    id = n.mark,
    end_row = n.end_row,
    end_col = #vim.api.nvim_buf_get_lines(buf, n.end_row, n.end_row + 1, false)[1],
    virt_text = { { "  » " .. n.text, "ClaudeNote" } },
    virt_text_pos = "eol",
    number_hl_group = "ClaudeNoteNr",
  })
end

-- Start row of the copy of `code` in `lines` closest to `near`.
local function find(lines, code, near)
  local best
  for r = 0, #lines - #code do
    local hit = true
    for i = 1, #code do
      if lines[r + i] ~= code[i] then
        hit = false
        break
      end
    end
    if hit and (not best or math.abs(r - near) < math.abs(best - near)) then best = r end
  end
  return best
end

-- A reload from disk leaves extmarks at their old rows even when lines were inserted
-- above them, so move each note to where its code is now. Notes whose code is gone stay.
local function reanchor(buf)
  local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
  for _, n in ipairs(notes) do
    if n.buf == buf then
      sync(n)
      local r = find(lines, n.code, n.row)
      if r then n.row, n.end_row = r, r + #n.code - 1 end
      place(n, buf)
    end
  end
end

local function note_at(buf, row)
  for _, n in ipairs(notes) do
    if n.buf == buf then
      sync(n)
      if row >= n.row and row <= n.end_row then return n end
    end
  end
end

local function remove(n)
  if attached(n) then vim.api.nvim_buf_del_extmark(n.buf, ns, n.mark) end
  for i, other in ipairs(notes) do
    if other == n then
      table.remove(notes, i)
      return
    end
  end
end

-- All notes, positions current, sorted by file then line.
function M.notes()
  for _, n in ipairs(notes) do sync(n) end
  local list = vim.list_slice(notes)
  table.sort(list, function(a, b)
    if a.path ~= b.path then return a.path < b.path end
    return a.row < b.row
  end)
  return list
end

-- Normal mode: note on the cursor line, or edit the note covering it.
-- Visual mode: new note on the selected lines.
function M.note()
  local buf = vim.api.nvim_get_current_buf()
  local path = vim.api.nvim_buf_get_name(buf)
  -- `://` catches diffview's old-revision buffers, whose line numbers aren't the file's.
  if vim.bo[buf].buftype ~= "" or path == "" or path:find("://", 1, true) then
    vim.notify("Claude notes: not a file buffer", vim.log.levels.WARN)
    return
  end
  local row, end_row, existing
  if vim.fn.mode():find("^[vV\22]") then
    row, end_row = vim.fn.line("v") - 1, vim.fn.line(".") - 1
    if row > end_row then row, end_row = end_row, row end
    vim.api.nvim_feedkeys(vim.keycode("<Esc>"), "nx", false)
  else
    row = vim.fn.line(".") - 1
    end_row = row
    existing = note_at(buf, row)
  end
  vim.ui.input({
    prompt = existing and "Edit note (empty deletes): " or "Note: ",
    default = existing and existing.text,
  }, function(text)
    if text == nil then return end
    text = vim.trim(text)
    if existing then
      if text == "" then
        remove(existing)
        return
      end
      existing.text = text
      place(existing, buf)
      snapshot(existing)
    elseif text ~= "" then
      local n = { path = path, text = text, row = row, end_row = end_row }
      table.insert(notes, n)
      place(n, buf)
      snapshot(n)
    end
  end)
end

function M.jump(dir)
  local buf = vim.api.nvim_get_current_buf()
  local rows = {}
  for _, n in ipairs(notes) do
    if n.buf == buf then
      sync(n)
      table.insert(rows, n.row)
    end
  end
  if #rows == 0 then
    vim.notify("Claude notes: none in this buffer")
    return
  end
  table.sort(rows)
  local cur = vim.fn.line(".") - 1
  local target = dir > 0 and rows[1] or rows[#rows]
  for i = 1, #rows do
    local r = dir > 0 and rows[i] or rows[#rows + 1 - i]
    if (dir > 0 and r > cur) or (dir < 0 and r < cur) then
      target = r
      break
    end
  end
  vim.cmd("normal! " .. (target + 1) .. "G^")
end

function M.to_quickfix()
  local items = vim.tbl_map(function(n)
    return { filename = n.path, lnum = n.row + 1, end_lnum = n.end_row + 1, text = n.text }
  end, M.notes())
  if #items == 0 then
    vim.notify("Claude notes: none")
    return
  end
  vim.fn.setqflist({}, " ", { title = "Claude notes", items = items })
  vim.cmd("copen")
end

function M.render()
  local out = {
    "# Review notes",
    "",
    "Address each note below. Each heading is `path:line`; the code block is the code the note refers to.",
  }
  for _, n in ipairs(M.notes()) do
    local loc = n.row == n.end_row and tostring(n.row + 1) or (n.row + 1) .. "-" .. (n.end_row + 1)
    local longest = 2
    for _, line in ipairs(n.code) do
      for run in line:gmatch("`+") do longest = math.max(longest, #run) end
    end
    local fence = string.rep("`", longest + 1)
    vim.list_extend(out, { "", "## " .. n.path .. ":" .. loc, "", fence .. (vim.filetype.match({ filename = n.path }) or "") })
    vim.list_extend(out, n.code)
    vim.list_extend(out, { fence, "", n.text })
  end
  return out
end

function M.clear()
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    vim.api.nvim_buf_clear_namespace(buf, ns, 0, -1)
  end
  notes = {}
end

function M.send()
  local count = #notes
  if count == 0 then
    vim.notify("Claude notes: none to send")
    return
  end
  local file = vim.fn.getcwd() .. "/.claude/notes.md"
  vim.fn.mkdir(vim.fs.dirname(file), "p")
  vim.fn.writefile(M.render(), file)
  local cc = require("claudecode")
  if not cc.is_claude_connected() then
    vim.notify("Claude not connected (run /ide). Notes saved to " .. file, vim.log.levels.WARN)
    return
  end
  local ok, err = cc.send_at_mention(file, nil, nil, "claude_notes")
  if not ok then
    vim.notify("Claude notes: send failed: " .. tostring(err), vim.log.levels.ERROR)
    return
  end
  M.clear()
  vim.notify(("Sent %d note%s to Claude"):format(count, count == 1 and "" or "s"))
end

vim.api.nvim_create_autocmd("BufUnload", {
  group = group,
  callback = function(ev)
    for _, n in ipairs(notes) do
      if n.buf == ev.buf then
        sync(n)
        n.buf, n.mark = nil, nil
      end
    end
  end,
})

-- Fires on reopen and on reload from disk (checktime, :e!).
vim.api.nvim_create_autocmd("BufReadPost", {
  group = group,
  callback = function(ev)
    local path = vim.api.nvim_buf_get_name(ev.buf)
    local any = false
    for _, n in ipairs(notes) do
      if n.path == path then
        if n.buf ~= ev.buf then n.buf, n.mark = ev.buf, nil end
        any = true
      end
    end
    if any then reanchor(ev.buf) end
  end,
})

-- Your own edits move extmarks correctly; refresh the code reanchor() searches for.
vim.api.nvim_create_autocmd("BufWritePost", {
  group = group,
  callback = function(ev)
    for _, n in ipairs(notes) do
      if n.buf == ev.buf then
        sync(n)
        snapshot(n)
      end
    end
  end,
})

vim.api.nvim_create_user_command("ClaudeNotesClear", function() M.clear() end, { desc = "Delete all Claude notes" })

vim.keymap.set({ "n", "x" }, "<leader>n", M.note, { desc = "Claude note: add / edit (empty deletes)" })
vim.keymap.set("n", "]n", function() M.jump(1) end, { desc = "Next Claude note" })
vim.keymap.set("n", "[n", function() M.jump(-1) end, { desc = "Previous Claude note" })
vim.keymap.set("n", "<leader>al", M.to_quickfix, { desc = "Claude notes to quickfix" })
vim.keymap.set("n", "<leader>an", M.send, { desc = "Send notes to Claude" })

return M
