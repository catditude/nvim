-- Periodically fetches git ahead/behind counts and exposes them as vim.g globals.
--
-- Resolves the repo from the current buffer, not nvim's cwd: in a multi-repo
-- workspace (Brazil src/<pkg>) the cwd is often not a git repo at all, and even
-- when it is, it's the wrong repo for whichever buffer you're looking at.
local review = require("review")

local function clear()
  vim.g._git_ahead = 0
  vim.g._git_behind = 0
end

local function update()
  local root = review.repo_root()
  if not root then
    vim.schedule(clear)
    return
  end

  vim.system(
    { "git", "-C", root, "rev-list", "--left-right", "--count", "HEAD...@{upstream}" },
    { text = true },
    function(result)
      if result.code == 0 and result.stdout then
        local ahead, behind = result.stdout:match("(%d+)%s+(%d+)")
        vim.schedule(function()
          vim.g._git_ahead = tonumber(ahead) or 0
          vim.g._git_behind = tonumber(behind) or 0
        end)
      else
        vim.schedule(clear)
      end
    end
  )
end

update()

local timer = vim.uv.new_timer()
timer:start(30000, 30000, vim.schedule_wrap(update))

-- BufEnter so the counts follow you across packages.
vim.api.nvim_create_autocmd({ "FocusGained", "BufWritePost", "BufEnter" }, {
  callback = update,
})

vim.api.nvim_create_autocmd("VimLeavePre", {
  callback = function()
    timer:stop()
    timer:close()
  end,
})
