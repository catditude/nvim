return {
    "rmagatti/auto-session",
    ---@module "auto-session"
    ---@type AutoSession.Config
    opts = {
        suppressed_dirs = { "~/", "~/Downloads", "/" },
        auto_restore = false,
        bypass_save_filetypes = { "snacks_dashboard" },
    },
}
