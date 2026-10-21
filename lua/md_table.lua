-- Show the markdown pipe table under the cursor in a float, with cells word-wrapped
-- to fit the screen. Markdown rows are single lines and render-markdown can't wrap
-- cells, so wide tables otherwise run off screen.
local M = {}

local width = vim.fn.strdisplaywidth

local function is_delimiter(line)
  return line:match("^[%s|:%-]+$") ~= nil and line:find("%-") ~= nil
end

-- Split a row on |, ignoring escaped \| and pipes inside `code`.
local function split_row(line)
  local cells, cur, in_code, i = {}, {}, false, 1
  line = vim.trim(line)
  while i <= #line do
    local c = line:sub(i, i)
    if c == "\\" and line:sub(i + 1, i + 1) == "|" then
      table.insert(cur, "|")
      i = i + 1
    elseif c == "`" then
      in_code = not in_code
      table.insert(cur, c)
    elseif c == "|" and not in_code then
      table.insert(cells, table.concat(cur))
      cur = {}
    else
      table.insert(cur, c)
    end
    i = i + 1
  end
  table.insert(cells, table.concat(cur))
  -- Leading/trailing pipes produce empty edge cells.
  if line:sub(1, 1) == "|" then table.remove(cells, 1) end
  if line:sub(-1) == "|" and not line:match("\\|$") then table.remove(cells) end
  return vim.tbl_map(function(s)
    s = vim.trim(s)
    s = s:gsub("%[([^%]]*)%]%b()", "%1") -- [text](url) -> text
    s = s:gsub("%*%*", ""):gsub("__", ""):gsub("`", "")
    return s
  end, cells)
end

local function alignment(cell)
  cell = vim.trim(cell)
  local l, r = cell:sub(1, 1) == ":", cell:sub(-1) == ":"
  return (l and r) and "center" or r and "right" or "left"
end

-- Word-wrap text to max display width w; words longer than w are hard-split.
local function wrap(text, w)
  local out, line = {}, ""
  for word in text:gmatch("%S+") do
    while width(word) > w do
      local head = vim.fn.strcharpart(word, 0, w)
      while width(head) > w do head = vim.fn.strcharpart(head, 0, vim.fn.strchars(head) - 1) end
      if line ~= "" then table.insert(out, line); line = "" end
      table.insert(out, head)
      word = vim.fn.strcharpart(word, vim.fn.strchars(head))
    end
    if line == "" then
      line = word
    elseif width(line) + 1 + width(word) <= w then
      line = line .. " " .. word
    else
      table.insert(out, line)
      line = word
    end
  end
  if line ~= "" or #out == 0 then table.insert(out, line) end
  return out
end

-- Fit natural column widths into avail: columns narrower than an even share keep
-- their width, the rest split what's left.
local function fit(natural, avail)
  local total = 0
  for _, w in ipairs(natural) do total = total + w end
  if total <= avail then return natural end
  local widths, open = {}, {}
  for i = 1, #natural do open[i] = true end
  local remaining, n = avail, #natural
  local changed = true
  while changed and n > 0 do
    changed = false
    local share = math.floor(remaining / n)
    for i, w in ipairs(natural) do
      if open[i] and w <= share then
        widths[i], open[i] = w, nil
        remaining, n, changed = remaining - w, n - 1, true
      end
    end
  end
  local share = n > 0 and math.max(1, math.floor(remaining / n)) or 0
  local extra = remaining - share * n
  for i in ipairs(natural) do
    if open[i] then
      widths[i] = share + (extra > 0 and 1 or 0)
      extra = extra - 1
    end
  end
  return widths
end

local function pad(text, w, align)
  local gap = w - width(text)
  if align == "right" then return string.rep(" ", gap) .. text end
  if align == "center" then
    local l = math.floor(gap / 2)
    return string.rep(" ", l) .. text .. string.rep(" ", gap - l)
  end
  return text .. string.rep(" ", gap)
end

--- Render table source lines into box-drawn lines no wider than max_width.
---@param src string[] table lines: header, delimiter, body rows
---@param max_width integer
---@return string[] lines, {start: integer, height: integer}[] spans 0-based line span per row (1 = header)
function M.render(src, max_width)
  local header = split_row(src[1])
  local ncol = #header
  local aligns = vim.tbl_map(alignment, split_row(src[2]))
  local rows = { header }
  for i = 3, #src do
    local r = split_row(src[i])
    for c = #r + 1, ncol do r[c] = "" end
    table.insert(rows, r)
  end

  local natural = {}
  for c = 1, ncol do
    natural[c] = 1
    for _, r in ipairs(rows) do natural[c] = math.max(natural[c], width(r[c] or "")) end
  end
  -- Each column costs its text plus 3 (" " .. text .. " " and one bar); +1 closing bar.
  local widths = fit(natural, math.max(ncol, max_width - 3 * ncol - 1))

  local function rule(l, m, r)
    local parts = {}
    for c = 1, ncol do parts[c] = string.rep("─", widths[c] + 2) end
    return l .. table.concat(parts, m) .. r
  end

  local out = { rule("╭", "┬", "╮") }
  local spans = {}
  for ri, r in ipairs(rows) do
    local wrapped, height = {}, 1
    for c = 1, ncol do
      wrapped[c] = wrap(r[c] or "", widths[c])
      height = math.max(height, #wrapped[c])
    end
    spans[ri] = { start = #out, height = height }
    for h = 1, height do
      local parts = {}
      for c = 1, ncol do
        parts[c] = " " .. pad(wrapped[c][h] or "", widths[c], ri == 1 and "left" or aligns[c]) .. " "
      end
      table.insert(out, "│" .. table.concat(parts, "│") .. "│")
    end
    if ri < #rows then table.insert(out, rule("├", "┼", "┤")) end
  end
  table.insert(out, rule("╰", "┴", "╯"))
  return out, spans
end

--- Find the pipe table around the cursor.
---@return string[]? src, integer? first 1-based line of the table
local function table_at_cursor(win)
  local buf = vim.api.nvim_win_get_buf(win)
  local row = vim.api.nvim_win_get_cursor(win)[1]
  local function is_row(n)
    local l = vim.api.nvim_buf_get_lines(buf, n - 1, n, false)[1]
    return l and l:find("|") and vim.trim(l) ~= ""
  end
  if not is_row(row) then return nil end
  local first, last = row, row
  while first > 1 and is_row(first - 1) do first = first - 1 end
  while is_row(last + 1) do last = last + 1 end
  local src = vim.api.nvim_buf_get_lines(buf, first - 1, last, false)
  if #src < 2 or not is_delimiter(src[2]) then return nil end
  return src, first
end

local ns = vim.api.nvim_create_namespace("md_table")
local ns_row = vim.api.nvim_create_namespace("md_table_row")

local function fill(buf, lines, spans)
  vim.bo[buf].modifiable = true
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.bo[buf].modifiable = false
  vim.api.nvim_buf_clear_namespace(buf, ns, 0, -1)
  local head = spans[1]
  for i = 0, #lines - 1 do
    local in_head = i >= head.start and i < head.start + head.height
    vim.api.nvim_buf_set_extmark(buf, ns, i, 0, {
      end_col = #lines[i + 1],
      hl_group = in_head and "RenderMarkdownTableHead" or "RenderMarkdownTableRow",
      priority = 100, -- below MdTableBorder (200); the default 4096 would hide it
    })
    local line = lines[i + 1]
    if line:sub(1, #"│") ~= "│" then
      -- Rule line: all box drawing.
      vim.api.nvim_buf_set_extmark(buf, ns, i, 0, { end_col = #line, hl_group = "MdTableBorder", priority = 200 })
    else
      local col = line:find("│", 1, true)
      while col do
        vim.api.nvim_buf_set_extmark(buf, ns, i, col - 1, { end_col = col - 1 + #"│", hl_group = "MdTableBorder", priority = 200 })
        col = line:find("│", col + #"│", true)
      end
    end
  end
end

function M.open()
  local src = table_at_cursor(0)
  if not src then
    vim.notify("No markdown table under cursor", vim.log.levels.WARN)
    return
  end
  local lines, spans = M.render(src, vim.o.columns - 4)

  local buf = vim.api.nvim_create_buf(false, true)
  vim.bo[buf].bufhidden = "wipe"
  fill(buf, lines, spans)

  local w = width(lines[1])
  local h = math.min(#lines, vim.o.lines - 4)
  local win = vim.api.nvim_open_win(buf, true, {
    relative = "editor",
    width = w,
    height = h,
    row = math.floor((vim.o.lines - h) / 2) - 1,
    col = math.floor((vim.o.columns - w) / 2),
    style = "minimal",
    border = "rounded",
    title = " table ",
    title_pos = "center",
  })
  vim.wo[win].winhighlight = "FloatBorder:MdTableBorder,FloatTitle:MdTableBorder"
  vim.wo[win].wrap = false
  vim.wo[win].cursorline = true
  for _, key in ipairs({ "q", "<Esc>" }) do
    vim.keymap.set("n", key, "<cmd>close<CR>", { buffer = buf, nowait = true })
  end
  vim.api.nvim_create_autocmd("WinLeave", {
    buffer = buf,
    once = true,
    callback = function()
      if vim.api.nvim_win_is_valid(win) then vim.api.nvim_win_close(win, true) end
    end,
  })
end

-- Auto-peek: while the cursor (normal mode) is in a table too wide for the window,
-- a non-focusable float drawn over the table shows the wrapped version. The row
-- under the cursor is highlighted and kept in view.

---@type table<integer, {win: integer, buf: integer, key: string, spans: table}>
local peeks = {} -- by source window

local function close_peek(win)
  local p = peeks[win]
  if not p then return end
  peeks[win] = nil
  if vim.api.nvim_win_is_valid(p.win) then vim.api.nvim_win_close(p.win, true) end
  if vim.api.nvim_buf_is_valid(p.buf) then vim.api.nvim_buf_delete(p.buf, { force = true }) end
end

local function update(win)
  if vim.api.nvim_get_mode().mode ~= "n" or vim.api.nvim_win_get_config(win).relative ~= "" then
    return close_peek(win)
  end
  local src, first = table_at_cursor(win)
  if not src then return close_peek(win) end

  local info = vim.fn.getwininfo(win)[1]
  local avail = info.width - info.textoff

  -- Anchor at the table's first line, or the window's top line if that's scrolled off.
  local anchor = math.max(first, info.topline)
  local key = table.concat(src, "\n") .. "\0" .. avail .. "\0" .. anchor
  local p = peeks[win]
  if not (p and p.key == key and vim.api.nvim_win_is_valid(p.win)) then
    close_peek(win)
    -- Fits unwrapped: render-markdown already draws it fine.
    if width(M.render(src, math.huge)[1]) <= avail then return end
    local lines, spans = M.render(src, avail)
    local buf = vim.api.nvim_create_buf(false, true)
    vim.bo[buf].bufhidden = "wipe"
    fill(buf, lines, spans)
    -- Start one screen line up to cover render-markdown's top edge of the table,
    -- unless the table starts at the top of the window.
    local shift = anchor > info.topline and 1 or 0
    local space = info.height - (anchor - info.topline) + shift
    local pwin = vim.api.nvim_open_win(buf, false, {
      relative = "win",
      win = win,
      bufpos = { anchor - 1, 0 },
      row = -shift,
      col = 0,
      width = width(lines[1]),
      height = math.max(1, math.min(#lines, space)),
      style = "minimal",
      focusable = false,
      zindex = 40,
    })
    vim.wo[pwin].winhighlight = "NormalFloat:Normal"
    vim.wo[pwin].wrap = false
    p = { win = pwin, buf = buf, key = key, spans = spans }
    peeks[win] = p
  end

  -- Source line -> table row: header and delimiter map to the header.
  local idx = vim.api.nvim_win_get_cursor(win)[1] - first + 1
  local span = p.spans[math.max(1, idx - 1)]
  vim.api.nvim_buf_clear_namespace(p.buf, ns_row, 0, -1)
  for i = span.start, span.start + span.height - 1 do
    vim.api.nvim_buf_set_extmark(p.buf, ns_row, i, 0, { line_hl_group = "CursorLine" })
  end
  vim.api.nvim_win_call(p.win, function()
    local h = vim.api.nvim_win_get_height(0)
    local top = vim.fn.line("w0") - 1
    if span.start < top or span.start + span.height > top + h then
      vim.fn.winrestview({ topline = math.max(1, span.start) })
    end
  end)
end

--- Enable auto-peek for a markdown buffer.
function M.attach(buf)
  if buf == 0 then buf = vim.api.nvim_get_current_buf() end
  local group = vim.api.nvim_create_augroup("md_table_" .. buf, { clear = true })
  vim.api.nvim_create_autocmd({ "CursorMoved", "TextChanged", "InsertLeave", "WinScrolled", "WinResized", "BufWinEnter", "WinEnter" }, {
    group = group,
    buffer = buf,
    callback = function() update(vim.api.nvim_get_current_win()) end,
  })
  vim.api.nvim_create_autocmd({ "InsertEnter", "BufLeave", "WinLeave" }, {
    group = group,
    buffer = buf,
    callback = function() close_peek(vim.api.nvim_get_current_win()) end,
  })
end

return M
