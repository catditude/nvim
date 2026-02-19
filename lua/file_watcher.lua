local group = vim.api.nvim_create_augroup("file_watcher", {})
local watchers = {}

local function stop_watch(bufnr)
    if watchers[bufnr] then
        watchers[bufnr]:stop()
        watchers[bufnr] = nil
    end
end

local function start_watch(bufnr)
    bufnr = bufnr or vim.api.nvim_get_current_buf()
    local filepath = vim.api.nvim_buf_get_name(bufnr)
    if filepath == "" then return end

    if watchers[bufnr] then
        watchers[bufnr]:stop()
    end

    local w = vim.uv.new_fs_poll()
    w:start(filepath, 1000, vim.schedule_wrap(function(err)
        if err or not vim.api.nvim_buf_is_valid(bufnr) then return end
        vim.api.nvim_buf_call(bufnr, function()
            vim.cmd("checktime")
        end)
    end))
    watchers[bufnr] = w
end

vim.api.nvim_create_autocmd("BufEnter", {
    group = group,
    callback = function(args)
        start_watch(args.buf)
    end,
})

vim.api.nvim_create_autocmd("BufDelete", {
    group = group,
    callback = function(args)
        stop_watch(args.buf)
    end,
})
