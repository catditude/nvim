-- Ctrl-h/j/k/l from the file tree. Its list is a float, and vim-tmux-navigator's
-- `wincmd h` from a float lands on a normal window, so it never hands off to tmux.
-- Look for a neighbor from the tree's sidebar split instead; none means tmux.
local function tree_nav(dir)
    return function(picker)
        local target = vim.api.nvim_win_call(picker.layout.root.win, function()
            local n = vim.fn.winnr(dir)
            return n ~= vim.fn.winnr() and vim.fn.win_getid(n) or nil
        end)
        if target then
            vim.api.nvim_set_current_win(target)
        elseif vim.env.TMUX then
            local flag = ({ h = "-L", j = "-D", k = "-U", l = "-R" })[dir]
            vim.fn.system({ "tmux", "-S", vim.split(vim.env.TMUX, ",")[1], "select-pane", "-t", vim.env.TMUX_PANE, flag })
        end
    end
end

-- Window the tree opens files in: the picker's main window, else the first normal one.
local function file_win(picker)
    if vim.api.nvim_win_is_valid(picker.main) then return picker.main end
    for _, w in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
        if vim.api.nvim_win_get_config(w).relative == "" and vim.bo[vim.api.nvim_win_get_buf(w)].buftype == "" then
            return w
        end
    end
end

-- Tree item under the mouse, with the list cursor moved onto it. The click has already
-- moved focus to the tree, but CursorMoved hasn't synced the list yet, and a fast second
-- click on another row arrives as a double-click.
local function mouse_item(picker)
    local m = vim.fn.getmousepos()
    if m.winid ~= picker.list.win.win or m.line == 0 then return end
    local top = vim.api.nvim_win_call(m.winid, vim.fn.winsaveview).topline
    local idx = picker.list:row2idx(m.line - top + 1)
    local item = picker.list:get(idx)
    if item then picker.list:move(idx, true) end
    return item
end

-- Enter / l / single click on a file: preview tab (lua/tree_preview.lua), focus stays in
-- the tree. Enter again on the file already shown: pin it and move into it. A click only
-- previews; the double-click pins (its first click must not move focus out of the tree).
-- Folders and search results keep the explorer's own confirm.
local function tree_confirm(picker, item, action, click)
    local win = file_win(picker)
    if not item or item.dir or picker.input.filter.meta.searching or not win then
        return require("snacks.explorer.actions").actions.confirm(picker, item, action)
    end
    local tp = require("tree_preview")
    if click then
        tp.open(item.file, win)
    elseif tp.tree_open(item.file, win) then
        vim.api.nvim_set_current_win(win)
    end
end

return {
    "folke/snacks.nvim",
    priority = 1000,
    lazy = false,
    init = function()
        vim.api.nvim_create_autocmd("User", {
            pattern = "SnacksDashboardOpened",
            once = true,
            callback = function()
                vim.defer_fn(Snacks.dashboard.update, 100)
            end,
        })
        -- Hide statusline/tabline on dashboard. The SnacksDashboardOpened autocmd
        -- handles subsequent opens, but on startup lualine loads later (VeryLazy)
        -- and overrides these values — see the config function in lualine.lua
        -- which re-applies after setup(). Both pieces are required.
        vim.api.nvim_create_autocmd("User", {
            pattern = "SnacksDashboardOpened",
            callback = function()
                vim.o.showtabline = 0
                vim.o.laststatus = 0
            end,
        })
        vim.api.nvim_create_autocmd("User", {
            pattern = "SnacksDashboardClosed",
            callback = function()
                vim.o.showtabline = 2
                vim.o.laststatus = 3
            end,
        })
        -- Bind <CR> to restore session on the dashboard buffer.
        -- Use UpdatePost so the keymap survives dashboard refreshes
        -- (e.g. the deferred update on line 10 re-runs :keys() and
        -- overwrites buffer-local mappings set earlier).
        vim.api.nvim_create_autocmd("User", {
            pattern = "SnacksDashboardUpdatePost",
            callback = function()
                local buf = vim.api.nvim_get_current_buf()
                if vim.bo[buf].filetype == "snacks_dashboard" then
                    vim.keymap.set("n", "<CR>", "<cmd>AutoSession restore<CR>", { buffer = buf })
                end
            end,
        })
    end,
    keys = {
        { "<leader>z", function() Snacks.zen() end, desc = "Zen: 100-column reading view" },
        { "<leader>e", function() Snacks.explorer() end, desc = "File tree (toggle)" },
        {
            "-",
            function()
                local tree = Snacks.picker.get({ source = "explorer" })[1]
                if vim.bo.buftype == "" and vim.api.nvim_buf_get_name(0) ~= "" then
                    Snacks.explorer.reveal()
                elseif not tree then
                    Snacks.explorer()
                end
                -- A newly opened tree takes focus itself; an open one needs it moved.
                if tree then tree:focus("list") end
            end,
            desc = "File tree: jump to the current file",
        },
    },
    ---@type snacks.Config
    opts = {
        -- Reading view: text centered in a fixed-width float. Width covers the number
        -- column (4) plus 100 columns of text.
        zen = { toggles = { dim = false } },
        styles = {
            zen = {
                width = 104,
                -- Solid instead of the default 40% see-through black, so text behind
                -- zen is hidden. blend = 0 with transparent = false uses bg as-is.
                backdrop = {
                    transparent = false,
                    blend = 0,
                    bg = string.format("#%06x", vim.api.nvim_get_hl(0, { name = "ZenBackdrop" }).bg or 0),
                },
            },
        },
        -- Back vim.ui.select with the snacks picker (a proper float). The built-in
        -- select renders as a numbered inputlist through the message area, which
        -- noice then reformats into a ragged, indented list; this replaces it and
        -- fixes every vim.ui.select site (review picker, LSP code actions, etc.).
        -- ui_select is registered eagerly in init below; picker.enabled alone only
        -- wires it lazily on first picker use.
        picker = {
            enabled = true,
            ui_select = true,
            sources = {
                explorer = {
                    -- Dotfiles shown (as oil had them); gitignored files stay hidden.
                    hidden = true,
                    layout = {
                        -- The search box shows only while you type in it (`/`): hidden at
                        -- open, and auto_hide hides it again when you leave it.
                        hidden = { "input" },
                        auto_hide = { "input" },
                        -- 30 wide (default 40) so code keeps ~105 of a 136-column pane.
                        layout = { width = 30, min_width = 30 },
                    },
                    actions = {
                        -- Not named `confirm`: the explorer's setup overwrites that action.
                        tree_open = tree_confirm,
                        tree_click = function(picker)
                            local item = mouse_item(picker)
                            if item then tree_confirm(picker, item, nil, true) end
                        end,
                        tree_double_click = function(picker)
                            local item, win = mouse_item(picker), file_win(picker)
                            if not item or item.dir or not win then return end
                            require("tree_preview").open_pinned(item.file, win)
                            vim.api.nvim_set_current_win(win)
                        end,
                        tree_nav_h = tree_nav("h"),
                        tree_nav_j = tree_nav("j"),
                        tree_nav_k = tree_nav("k"),
                        tree_nav_l = tree_nav("l"),
                        back_to_file = function(picker)
                            if vim.api.nvim_win_is_valid(picker.main) then vim.api.nvim_set_current_win(picker.main) end
                        end,
                        -- Leaving the search box hides it, so also clear the filter;
                        -- otherwise the tree keeps showing only the matches.
                        search_done = function(picker)
                            picker.input:set("", "")
                            picker:focus("list", { show = true })
                        end,
                    },
                    win = {
                        -- Default Esc in the search box closes the tree too.
                        input = { keys = { ["<Esc>"] = { "search_done", mode = { "n", "i" } } } },
                        list = {
                            keys = {
                                ["-"] = "explorer_up",
                                -- Pane navigation, like everywhere else (default C-j/C-k move in the list).
                                ["<C-h>"] = "tree_nav_h",
                                ["<C-j>"] = "tree_nav_j",
                                ["<C-k>"] = "tree_nav_k",
                                ["<C-l>"] = "tree_nav_l",
                                ["h"] = false, -- Enter already opens and closes folders
                                ["<CR>"] = "tree_open",
                                ["l"] = "tree_open",
                                ["<LeftRelease>"] = "tree_click",
                                ["<2-LeftMouse>"] = "tree_double_click",
                                -- Default Esc closes the tree; keep it open and go back to the file.
                                ["<Esc>"] = "back_to_file",
                            },
                        },
                    },
                },
            },
        },
        -- `nvim dir/` opens the tree instead of netrw.
        explorer = { enabled = true },
        dashboard = {
            preset = {
                header = table.concat({
			"⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣶⣿⣶⣦⣄⣀⣀⣀⣀⣀⣀⣀⣀⣀⣀⣤⣶⣾⣿⣿⣷⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀",
			"⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣿⣿⣿⣿⣿⠿⠿⠿⣿⣿⣿⣿⠿⠿⠿⢿⣿⣿⣿⣿⣿⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀",
			"⠀⠀⠀⠀⠀⢀⡀⣄⠀⠀⠀⠀⠀⠀⠀⣿⣿⠟⠉⠀⢀⣀⠀⠀⠈⠉⠀⠀⣀⣀⠀⠀⠙⢿⣿⣿⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀",
			"⠀⠀⠀⣀⣶⣿⣿⣿⣾⣇⠀⠀⠀⠀⢀⣿⠃⠀⠀⠀⠀⢀⣀⡀⠀⠀⠀⣀⡀⠀⠀⠀⠀⠀⠹⣿⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀",
			"⠀⠀⠀⢻⣿⣿⣿⣿⣿⣿⣷⣄⠀⠀⣼⡏⠀⠀⠀⣀⣀⣉⠉⠩⠭⠭⠭⠥⠤⢀⣀⣀⠀⠀⠀⢻⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀",
			"⠀⠀⠀⣸⣿⣿⣿⣿⣿⣿⣿⣿⣷⣄⣿⠷⠒⠋⠉⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠉⠑⠒⠼⣧⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀",
			"⠀⠀⠀⢹⣿⣿⣿⣿⣿⣿⣿⣿⡿⠋⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠳⣦⣀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀",
			"⠀⠀⠀⢸⣿⣿⣿⣿⣿⣿⡿⠋⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⢿⣷⣦⣀⠀⠀⠀⠀⠀⠀⠀⠀",
			"⠀⠀⠀⠈⣿⣿⣿⣿⣿⡟⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸⣿⣿⣿⣷⣄⠀⠀⠀⠀⠀⠀",
			"⠀⠀⠀⠀⢹⣿⣿⣿⣿⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸⣿⣿⣿⣿⣿⣷⣄⠀⠀⠀⠀",
			"⠀⠀⠀⠀⠀⣿⣿⣿⣿⡄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣠⣾⣿⣿⣿⣿⣿⣿⣿⣧⡀⠀⠀",
			"⠀⠀⠀⠀⢠⣿⣿⣿⣿⣿⣶⣤⣄⣠⣤⣤⣶⣶⣾⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣷⣶⣶⣶⣶⣶⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣷⠀⠀",
			"⠀⠀⠀⠀⢸⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣧⠀",
			"⠀⠀⣀⠀⢸⡿⠿⣿⡿⠋⠉⠛⠻⢿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠟⠉⠀⠻⠿⠟⠉⢙⣿⣿⣿⣿⣿⣿⡇",
			"⠀⠀⢿⣿⣿⠀⠀⠀⠀⠀⠀⠀⠀⠀⠙⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡟⠁⠀⠀⠀⠀⠀⠀⠀⠈⠻⠿⢿⡿⣿⠳⠀",
			"⠀⠀⡞⠛⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡿⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣇⡀⠀⠀",
			"⢀⣸⣀⡀⠀⠀⠀⠀⣠⣴⣾⣿⣷⣆⠀⢸⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡇⠀⣰⣿⣿⣿⣿⣷⣦⠀⠀⠀⠀⢿⣿⠿⠃⠀",
			"⠘⢿⡿⠃⠀⠀⠀⣸⣿⣿⣿⣿⣿⡿⢀⣾⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡀⢻⣿⣿⣿⣿⣿⣿⠂⠀⠀⠀⡸⠁⠀⠀⠀",
			"⠀⠀⠳⣄⠀⠀⠀⠹⣿⣿⣿⡿⠛⣠⠾⠿⠿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡿⠿⠿⠿⠳⣄⠙⠛⠿⠿⠛⠉⠀⠀⣀⠜⠁⠀⠀⠀⠀",
			"⠀⠀⠀⠈⠑⠢⠤⠤⠬⠭⠥⠖⠋⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠉⠒⠢⠤⠤⠤⠒⠊⠁⠀⠀⠀⠀⠀⠀",
                }, "\n"),
                keys = {},
            },
            sections = {
                {
                    text = {
                        { "󰧒 " .. os.date("%A, %B %d") .. "  ", hl = "SnacksDashboardHeader" },
                        { " " .. os.date("%I:%M %p"), hl = "SnacksDashboardHeader" },
                    },
                    align = "center",
                    padding = 1,
                },
                { section = "header" },
                {
                    icon = " ",
                    title = " Git Status",
                    section = "terminal",
                    enabled = function()
                    	return Snacks.git.get_root() ~= nil
		    end,
                    cmd = "git status --short --branch --renames",
                    height = 5,
                    padding = 1,
                    ttl = 5 * 60,
                    indent = 3,
                },
            },
        },
    },
}
