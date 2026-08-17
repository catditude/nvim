-- Side-by-side diff viewer with syntax highlighting and file history
return {
  "sindrets/diffview.nvim",
  cmd = { "DiffviewOpen", "DiffviewFileHistory" },
  keys = {
    -- No rev given, so this is index-relative: uncommitted work only.
    -- (--imply-local is inert without a range rev, but harmless.)
    { "<leader>gd", function() require("diff_layout").apply(); vim.cmd("DiffviewOpen --imply-local") end, desc = "Diff view (working tree)" },
    { "<leader>gh", function() require("diff_layout").apply(); vim.cmd("DiffviewFileHistory %") end, desc = "File history" },

    -- Committed review: upstream...HEAD, i.e. what a CR would show. See lua/review.lua.
    { "<leader>gc", function() require("review").review_pick() end, desc = "Review CR (all packages, or pick one)" },
    { "<leader>gq", function() require("review").changed_to_quickfix() end, desc = "Changed files to quickfix (all pkgs)" },
    { "<leader>gb", function() require("review").toggle_base() end, desc = "Toggle gitsigns base (index / upstream)" },
    { "<leader>gf", function() require("review").find_changed() end, desc = "Find in changed files (all pkgs)" },
    { "<leader>gg", function() require("review").grep_changed() end, desc = "Grep changed files (all pkgs)" },

    -- Uncommitted (vs HEAD) across all packages. Capitals are the uncommitted twins
    -- of the review commands above (gu pairs with gc).
    { "<leader>gu", function() require("review").worktree_pick() end, desc = "Uncommitted (all packages, or pick one)" },
    { "<leader>gQ", function() require("review").worktree_to_quickfix() end, desc = "Uncommitted files to quickfix (all pkgs)" },
    { "<leader>gF", function() require("review").worktree_find() end, desc = "Find in uncommitted files (all pkgs)" },
    { "<leader>gG", function() require("review").worktree_grep() end, desc = "Grep uncommitted files (all pkgs)" },
  },
  opts = {
    enhanced_diff_hl = true,
    file_panel = { listing_style = "tree", win_config = { width = 30 } },
    view = {
      default = { layout = "diff2_vertical", winbar_info = true },
      file_history = { layout = "diff2_vertical", winbar_info = true },
    },
    hooks = {
      diff_buf_read = function(bufnr)
        -- Trigger BufReadPost so treesitter-context recognizes diff buffers
        vim.api.nvim_exec_autocmds("BufReadPost", { buffer = bufnr })
      end,
      diff_buf_win_enter = function(bufnr, winid)
        -- Show full file content without folding unchanged lines.
        -- Drop this line to fold unchanged regions (default) and scroll less.
        vim.wo[winid].foldenable = false
      end,
      view_opened = function()
        -- Hide the default tabline (shows file paths when diffview creates a new tab)
        vim._diffview_saved_showtabline = vim.o.showtabline
        vim.opt.showtabline = 0
      end,
      view_closed = function()
        vim.opt.showtabline = vim._diffview_saved_showtabline or 1
        vim._diffview_saved_showtabline = nil
      end,
    },
    keymaps = {
      view = { q = "<cmd>DiffviewClose<cr>" },
      file_panel = { q = "<cmd>DiffviewClose<cr>" },
      file_history_panel = { q = "<cmd>DiffviewClose<cr>" },
    },
  },
}
