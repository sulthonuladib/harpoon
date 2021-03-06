local Path = require('plenary.path')
local float = require('plenary.window.float')
local Marked = require('harpoon.mark')

local factorw = 0.42069
local factorh = 0.69420

local M = {}

win_id = nil
bufh = nil

function create_window()
    local win_info = float.percentage_range_window(
        factorw,
        factorh,
        {
            winblend = 0
        })

    return win_info
end

M.toggle_quick_menu = function()
    if win_id ~= nil and vim.api.nvim_win_is_valid(win_id) then
        vim.api.nvim_win_close(win_id, true)

        win_id = nil
        bufh = nil

        return
    end

    local win_info = create_window()
    local contents = {}

    win_id = win_info.win_id
    bufh = win_info.bufh

    for idx = 1, Marked.get_length() do
        contents[idx] = string.format("%d %s", idx, Marked.get_marked_file(idx))
    end

    vim.api.nvim_buf_set_lines(bufh, 0, #contents, false, contents)
end

M.nav_file = function(id)
    idx = Marked.get_index_of(id)
    if not Marked.valid_index(idx) then
        return
    end

    local buf_id = vim.fn.bufnr(Marked.get_marked_file(idx))

    if vim.api.nvim_win_is_valid(buf_id) then
        vim.api.nvim_win_close(win_id)
    end

    if buf_id ~= nil and buf_id ~= -1 then
        vim.api.nvim_set_current_buf(buf_id)
    else
        vim.cmd(string.format("e %s", Marked.get_marked_file(idx)))
    end
end

function M.location_window(options)
    local default_options = {
        relative = 'editor',
        style = 'minimal',
        width = 30,
        height = 15,
        row = 2,
        col = 2,
    }
    options = vim.tbl_extend('keep', options, default_options)

    local bufnr = options.bufnr or vim.fn.nvim_create_buf(false, true)
    local win_id = vim.fn.nvim_open_win(bufnr, true, options)

    return {
        bufnr = bufnr,
        win_id = win_id,
    }
end

function M.notification(text)
    local win_stats = vim.api.nvim_list_uis()[1]
    local win_width = win_stats.width

    local prev_win = vim.api.nvim_get_current_win()

    local info = M.location_window({
        width = 20,
        height = 2,
        row = 1,
        col = win_width - 21
    })

    vim.api.nvim_buf_set_lines(info.bufnr, 0, 5, false, {"!!! Notification", text})
    vim.api.nvim_set_current_win(prev_win)

    return {
        bufnr = info.bufnr,
        win_id = info.win_id
    }
end

function M.close_notification(bufnr)
    vim.api.nvim_buf_delete(bufnr)
end

return M

