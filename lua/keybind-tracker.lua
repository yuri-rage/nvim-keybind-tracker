--[[
Keybind Tracker Plugin for Neovim

Provides a toggleable floating window displaying tracked keybindings.
Use `require("keybind-tracker").map()` instead of `vim.keymap.set()` to
track mappings for display. Includes a `setup()` function to register a default
keybinding (e.g., <leader>kb) for toggling the popup.
--]]

local M = {}

M._tracked = {}

function M.map(mode, lhs, rhs, opts)
    opts = opts or {}
    vim.keymap.set(mode, lhs, rhs, opts)

    local desc = opts.desc or (type(rhs) == "string" and rhs) or "(function)"
    table.insert(M._tracked, {
        mode = mode,
        lhs = lhs,
        desc = desc,
    })
end

local win_id = nil
local buf_id = nil

local function generate_lines()
    local leader = vim.g.mapleader or "\\"
    local display_leader = leader == " " and "<SPACE>" or leader

    local lines = { string.format("Tracked Keybinds:   (<leader> = %s)", display_leader), "" }

    local filtered = vim.tbl_filter(function(map)
        return map.mode == "n" and map.lhs:find("^<leader>") or map.lhs:match("^[HLK]$") or map.lhs:find("^<C%-")
    end, M._tracked)

    table.sort(filtered, function(a, b)
        return a.lhs < b.lhs
    end)

    for _, map in ipairs(filtered) do
        table.insert(lines, string.format("  %-15s → %s", map.lhs, map.desc))
    end

    if #filtered == 0 then
        table.insert(lines, "  (No tracked mappings found)")
    end

    table.insert(lines, "") -- vertical pad bottom

    return lines
end

function M.toggle()
    if win_id and vim.api.nvim_win_is_valid(win_id) then
        vim.api.nvim_win_close(win_id, true)
        win_id = nil
        buf_id = nil
        return
    end

    buf_id = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_lines(buf_id, 0, -1, false, generate_lines())
    vim.api.nvim_buf_set_option(buf_id, "modifiable", false)
    vim.api.nvim_buf_set_option(buf_id, "bufhidden", "wipe")

    local width = 60
    local height = math.max(4, #vim.api.nvim_buf_get_lines(buf_id, 0, -1, false))
    local opts = {
        relative = "editor",
        width = width,
        height = height,
        row = 1,
        col = vim.o.columns - width - 3,
        style = "minimal",
        border = "rounded",
        noautocmd = true,
    }

    win_id = vim.api.nvim_open_win(buf_id, false, opts)
end

function M.setup(opts)
    opts = opts or {}
    -- register the keybinding to toggle the popup
    local key = opts.toggle_key or "<leader>kb"
    local desc = opts.toggle_desc or "Toggle this window"
    M.map("n", key, M.toggle, { desc = desc })
end

return M

