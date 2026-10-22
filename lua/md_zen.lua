-- Open markdown files in snacks.zen (100-column reading view) and let `q` close it.
local M = {}

local function in_zen(win)
  local z = Snacks.zen.win
  return z ~= nil and z:valid() and z.win == win
end

-- Only when the file is alone in its tab: splits, diffview and the review layout
-- keep their own window arrangement.
local function should_zen(buf, win)
  if vim.api.nvim_get_current_buf() ~= buf or vim.api.nvim_win_get_config(win).relative ~= "" then
    return false
  end
  if vim.wo[win].diff or vim.o.columns <= Snacks.config.styles.zen.width then return false end
  local zen = Snacks.zen.win
  if zen and zen:valid() then return false end
  for _, w in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    if w ~= win and vim.api.nvim_win_get_config(w).relative == "" then return false end
  end
  return true
end

function M.attach(buf)
  if buf == 0 then buf = vim.api.nvim_get_current_buf() end
  vim.api.nvim_create_autocmd("BufWinEnter", {
    group = vim.api.nvim_create_augroup("md_zen_" .. buf, { clear = true }),
    buffer = buf,
    callback = function()
      vim.schedule(function()
        if should_zen(buf, vim.api.nvim_get_current_win()) then Snacks.zen() end
      end)
    end,
  })
  -- Expr map: Snacks.zen() can't run under the mapping's textlock, so schedule it.
  vim.keymap.set("n", "q", function()
    if not in_zen(vim.api.nvim_get_current_win()) then return "q" end
    vim.schedule(function() Snacks.zen() end)
    return ""
  end, { buffer = buf, expr = true, desc = "Close zen (else record macro)" })
end

return M
