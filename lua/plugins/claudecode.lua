-- Claude Code IDE integration. Claude runs in its own tmux pane (provider "none");
-- run /ide in Claude to connect. Claude then sees the current file and selection,
-- and its proposed edits open here as diffs.
return {
    "coder/claudecode.nvim",
    -- /ide only finds an nvim whose server is already running.
    lazy = false,
    opts = {
        terminal = { provider = "none" },
    },
    keys = {
        { "<leader>a", nil, desc = "AI/Claude Code" },
        { "<leader>ab", "<cmd>ClaudeCodeAdd %<cr>", desc = "Add current buffer" },
        { "<leader>as", "<cmd>ClaudeCodeSend<cr>", mode = "v", desc = "Send selection to Claude" },
        { "<leader>as", "<cmd>ClaudeCodeTreeAdd<cr>", desc = "Add file to Claude", ft = { "oil" } },
        { "<leader>aa", "<cmd>ClaudeCodeDiffAccept<cr>", desc = "Accept Claude diff" },
        { "<leader>ad", "<cmd>ClaudeCodeDiffDeny<cr>", desc = "Deny Claude diff" },
    },
}
