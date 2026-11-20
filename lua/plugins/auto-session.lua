return {
    "rmagatti/auto-session",
    ---@module "auto-session"
    ---@type AutoSession.Config
    opts = {
        suppressed_dirs = { "~/", "~/Downloads", "/" },
        auto_restore = false,
        bypass_save_filetypes = { "snacks_dashboard" },
        -- Keep the file tree out of session files (lua/explorer_auto.lua).
        pre_save_cmds = { function() require("explorer_auto").before_save() end },
        post_save_cmds = { function() require("explorer_auto").after_save() end },
    },
}
