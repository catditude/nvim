-- Saves modified buffers on InsertLeave/TextChanged (1s debounce) and
-- immediately on BufLeave/FocusLost/QuitPre. :ASToggle turns it off.
return {
    "okuuva/auto-save.nvim",
    version = "^1.0.0",
    opts = {
        condition = function(buf)
            -- Special buffers. Both are acwrite: a write in an oil buffer applies its
            -- pending filesystem changes, and a write in a claudecode.nvim proposal
            -- accepts Claude's diff.
            if vim.fn.getbufvar(buf, "&buftype") ~= "" then return false end
            -- git is the editor here: quitting without saving must still abort.
            local ft = vim.fn.getbufvar(buf, "&filetype")
            return ft ~= "gitcommit" and ft ~= "gitrebase"
        end,
    },
}
