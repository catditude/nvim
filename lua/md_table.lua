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
-- Padding namespaces are scoped to one window each: the same buffer can be shown in
-- windows of different widths (e.g. a zen float over the normal window).
local function pad_ns(win)
  local ns = vim.api.nvim_create_namespace("md_table_pad_" .. win)
  vim.api.nvim__ns_set(ns, { wins = { win } })
  return ns
end

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

-- Overlays: every pipe table in view in a markdown window is covered by a
-- non-focusable float showing it with cells wrapped to the window width
-- (render-markdown's own table rendering is off). When the wrapped table is taller
-- than the raw lines, blank virtual lines under the table make room for it. In
-- insert mode the table under the cursor shows raw so edits are visible.

---@class md_table.Overlay
---@field key string
---@field lines string[]
---@field spans table
---@field buf integer
---@field win integer?
---@field height integer
---@field first integer
---@field last integer
---@field src_buf integer
---@field pad integer? extmark id in src_buf
---@field pad_ns integer?

---@type table<integer, table<integer, md_table.Overlay>> source window -> first line -> overlay
local state = {}

local function is_table_row(buf, n)
  local l = vim.api.nvim_buf_get_lines(buf, n - 1, n, false)[1]
  return l ~= nil and l:find("|") ~= nil and vim.trim(l) ~= ""
end

local function tables_in_view(buf, top, bot)
  local found = {}
  local n = top
  while n > 1 and is_table_row(buf, n - 1) do n = n - 1 end
  local count = vim.api.nvim_buf_line_count(buf)
  while n <= math.min(bot, count) do
    if is_table_row(buf, n) then
      local first = n
      while is_table_row(buf, n + 1) do n = n + 1 end
      local src = vim.api.nvim_buf_get_lines(buf, first - 1, n, false)
      if #src >= 2 and is_delimiter(src[2]) then
        table.insert(found, { first = first, last = n, src = src })
      end
    end
    n = n + 1
  end
  return found
end

local function clear_pad(o)
  if o.pad and vim.api.nvim_buf_is_valid(o.src_buf) then
    vim.api.nvim_buf_del_extmark(o.src_buf, o.pad_ns, o.pad)
  end
  o.pad = nil
end

local function hide(o)
  if o.win and vim.api.nvim_win_is_valid(o.win) then vim.api.nvim_win_close(o.win, true) end
  o.win = nil
end

local function destroy(o)
  hide(o)
  clear_pad(o)
  if vim.api.nvim_buf_is_valid(o.buf) then vim.api.nvim_buf_delete(o.buf, { force = true }) end
end

local function clear_window(win)
  local ov = state[win]
  if not ov then return end
  state[win] = nil
  for _, o in pairs(ov) do destroy(o) end
end

local function refresh(win)
  if not vim.api.nvim_win_is_valid(win) then return clear_window(win) end
  local src_buf = vim.api.nvim_win_get_buf(win)
  if not vim.b[src_buf].md_table then return clear_window(win) end

  local info = vim.fn.getwininfo(win)[1]
  local avail = info.width - info.textoff
  -- Just above the source window: under other floats (treesitter-context, popups),
  -- but above the window itself when that is a float (e.g. zen mode).
  local parent_z = vim.api.nvim_win_get_config(win).zindex
  local zindex = parent_z and parent_z + 1 or 10
  local mode = vim.api.nvim_get_mode().mode:sub(1, 1)
  local editing = (mode == "i" or mode == "R") and win == vim.api.nvim_get_current_win()
  local cursor = vim.api.nvim_win_get_cursor(win)[1]

  local old, ov = state[win] or {}, {}
  -- Pass 1: render and pad. Padding moves later text, so positions come after.
  for _, t in ipairs(tables_in_view(src_buf, info.topline, info.botline)) do
    local o = old[t.first]
    old[t.first] = nil
    local key = table.concat(t.src, "\n") .. "\0" .. avail
    if editing and cursor >= t.first and cursor <= t.last then
      if o then destroy(o) end
    else
      if not (o and o.key == key and vim.api.nvim_buf_is_valid(o.buf)) then
        if o then destroy(o) end
        local lines, spans = M.render(t.src, avail)
        local buf = vim.api.nvim_create_buf(false, true)
        vim.bo[buf].bufhidden = "hide" -- kept while the float is hidden; destroy() deletes it
        fill(buf, lines, spans)
        o = { key = key, lines = lines, spans = spans, buf = buf, src_buf = src_buf }
      end
      o.first, o.last = t.first, t.last
      -- start_vcol = 0 leaves out virtual lines above the table (e.g. a heading border).
      local raw = vim.api.nvim_win_text_height(win, { start_row = t.first - 1, start_vcol = 0, end_row = t.last - 1 }).all
      clear_pad(o)
      if #o.lines > raw then
        local vl = {}
        for i = 1, #o.lines - raw do vl[i] = { { "", "" } } end
        o.pad_ns = pad_ns(win)
        o.pad = vim.api.nvim_buf_set_extmark(src_buf, o.pad_ns, t.last - 1, 0, { virt_lines = vl })
      end
      o.height = math.max(#o.lines, raw)
      -- Raw lines taller than the rendered table: blank fill so they don't show through.
      if vim.api.nvim_buf_line_count(o.buf) ~= o.height then
        local fill_lines = vim.list_extend(vim.deepcopy(o.lines), vim.fn["repeat"]({ "" }, o.height - #o.lines))
        vim.bo[o.buf].modifiable = true
        vim.api.nvim_buf_set_lines(o.buf, 0, -1, false, fill_lines)
        vim.bo[o.buf].modifiable = false
      end
      ov[t.first] = o
    end
  end
  for _, o in pairs(old) do destroy(o) end
  state[win] = ov

  -- Pass 2: place each float over its table's screen rows.
  for _, o in pairs(ov) do
    local row, offset
    if o.first >= info.topline then
      local pos = vim.fn.screenpos(win, o.first, 1)
      row, offset = pos.row - info.winrow, 0
      if pos.row == 0 then row = nil end -- pushed below the window
    elseif o.last >= info.topline then
      row = 0
      offset = vim.api.nvim_win_text_height(win, { start_row = o.first - 1, start_vcol = 0, end_row = info.topline - 2 }).all
    else
      -- Table scrolled off the top, but its padding (virtual lines above topline)
      -- may still show as filler at the top of the window.
      row = 0
      local topfill = o.last + 1 == info.topline and vim.api.nvim_win_call(win, vim.fn.winsaveview).topfill or 0
      offset = o.height - topfill
    end
    local height = row and math.min(o.height - offset, info.height - row) or 0
    if height <= 0 then
      hide(o)
    else
      local cfg = {
        relative = "win",
        win = win,
        row = row,
        col = info.textoff,
        width = width(o.lines[1]),
        height = height,
        focusable = false,
        zindex = zindex,
      }
      if o.win and vim.api.nvim_win_is_valid(o.win) then
        vim.api.nvim_win_set_config(o.win, cfg)
      else
        cfg.style = "minimal"
        cfg.noautocmd = true
        o.win = vim.api.nvim_open_win(o.buf, false, cfg)
        vim.wo[o.win].winhighlight = "NormalFloat:Normal"
        vim.wo[o.win].wrap = false
        vim.wo[o.win].scrolloff = 0 -- global scrolloff=999 would re-center and undo topline
      end
      -- Cursor too: the view snaps back to keep the float's cursor visible.
      vim.api.nvim_win_set_cursor(o.win, { offset + 1, 0 })
      vim.api.nvim_win_call(o.win, function() vim.fn.winrestview({ topline = offset + 1 }) end)
    end

    -- Highlight the row under the cursor. Header and delimiter map to the header.
    vim.api.nvim_buf_clear_namespace(o.buf, ns_row, 0, -1)
    if cursor >= o.first and cursor <= o.last then
      local span = o.spans[math.max(1, cursor - o.first)]
      for i = span.start, span.start + span.height - 1 do
        vim.api.nvim_buf_set_extmark(o.buf, ns_row, i, 0, { line_hl_group = "CursorLine" })
      end
    end
  end
end

local function refresh_all()
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    -- Valid check: refreshing one window can close floats later in this list.
    if vim.api.nvim_win_is_valid(win) and (state[win] or vim.b[vim.api.nvim_win_get_buf(win)].md_table) then
      refresh(win)
    end
  end
  for win in pairs(state) do
    if not vim.api.nvim_win_is_valid(win) then clear_window(win) end
  end
end

local group = vim.api.nvim_create_augroup("md_table", { clear = true })
vim.api.nvim_create_autocmd(
  { "CursorMoved", "CursorMovedI", "InsertEnter", "InsertLeave", "TextChanged", "TextChangedI",
    "WinScrolled", "WinResized", "BufWinEnter", "BufEnter" },
  { group = group, callback = function() vim.schedule(refresh_all) end }
)

--- Enable table overlays for a markdown buffer.
function M.attach(buf)
  if buf == 0 then buf = vim.api.nvim_get_current_buf() end
  vim.b[buf].md_table = true
  vim.schedule(refresh_all)
end

return M
