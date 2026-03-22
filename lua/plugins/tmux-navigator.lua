return {
    "christoomey/vim-tmux-navigator",
    event = "VeryLazy",
    config = function()
        if not vim.env.TMUX then return end

        local tmux_socket = vim.split(vim.env.TMUX, ",")[1]
        local dir_to_cmd = { L = "Left", D = "Down", U = "Up", R = "Right", l = "Previous" }

        local function navigate_from_terminal(direction)
            return function()
                local cfg = vim.api.nvim_win_get_config(vim.api.nvim_get_current_win())
                if cfg.relative ~= "" and vim.bo.buftype == "terminal" then
                    -- Floating terminal (e.g. lazygit): talk directly to tmux
                    vim.fn.system({ "tmux", "-S", tmux_socket, "select-pane", "-" .. direction })
                else
                    -- Regular terminal split: use plugin's navigation
                    vim.cmd("TmuxNavigate" .. dir_to_cmd[direction])
                end
            end
        end

        vim.keymap.set("t", "<C-h>", navigate_from_terminal("L"), { silent = true })
        vim.keymap.set("t", "<C-j>", navigate_from_terminal("D"), { silent = true })
        vim.keymap.set("t", "<C-k>", navigate_from_terminal("U"), { silent = true })
        vim.keymap.set("t", "<C-l>", navigate_from_terminal("R"), { silent = true })
        vim.keymap.set("t", "<C-\\>", navigate_from_terminal("l"), { silent = true })
    end,
}
