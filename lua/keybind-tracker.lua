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

    -- Extract custom field and clone table to avoid mutating user's table
    local group = opts.group or ""
    local cleaned_opts = vim.tbl_deep_extend("force", {}, opts)
    cleaned_opts.group = nil

    vim.keymap.set(mode, lhs, rhs, cleaned_opts)

    local desc = opts.desc or (type(rhs) == "string" and rhs) or "(function)"
    table.insert(M._tracked, {
        mode = mode,
        lhs = lhs,
        desc = desc,
        group = group,
    })
end

local win_id = nil
local buf_id = nil
local width = 60 -- default width

local function mode_to_string(mode)
    local str
    if type(mode) == "string" then
        str = mode
    else
        table.sort(mode)
        str = table.concat(mode)
    end
    return str:upper()
end

local function generate_lines()
    local leader = vim.g.mapleader or "\\"
    local display_leader = leader == " " and "<SPACE>" or leader

    local lines = {
        string.format("Tracked Keybinds:      <leader> = %s", display_leader),
        "",
        "  MODE KEYBIND         → DESCRIPTION  ",
    }

    -- Group by group
    local groups = {}
    for _, map in ipairs(M._tracked) do
        local cat = map.group or "Uncategorized"
        groups[cat] = groups[cat] or {}
        table.insert(groups[cat], map)
    end

    -- Sort groups alphabetically
    local sorted_keys = vim.tbl_keys(groups)
    table.sort(sorted_keys)

    for _, group in ipairs(sorted_keys) do
        if group ~= "" then
            table.insert(lines, "  [" .. group .. "]")
        end
        for _, map in ipairs(groups[group]) do
            local mode = mode_to_string(map.mode)
            local line = string.format("  %-4s %-15s → %s", mode, map.lhs, map.desc)
            width = math.max(width, #line)
            table.insert(lines, line)
        end
        table.insert(lines, "") -- blank line after each group
    end

    if vim.tbl_count(M._tracked) == 0 then
        table.insert(lines, "  (No tracked keybinds found)")
        table.insert(lines, "")
    end

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
    local lines = generate_lines()
    vim.api.nvim_buf_set_lines(buf_id, 0, -1, false, lines)
    vim.api.nvim_buf_set_option(buf_id, "modifiable", false)
    vim.api.nvim_buf_set_option(buf_id, "bufhidden", "wipe")

    -- Apply highlights
    local ns_id = vim.api.nvim_create_namespace("KeybindTracker")
    local info_hl = vim.api.nvim_get_hl(0, { name = "Label" })
    vim.api.nvim_set_hl(0, "KeybindTitle", {
        fg = info_hl.fg,
        bold = true,
    })

    info_hl = vim.api.nvim_get_hl(0, { name = "QuickFixLine" })
    vim.api.nvim_set_hl(0, "KeybindLegend", {
        fg = info_hl.fg,
        underline = true,
    })

    -- apply styling
    for row, line in ipairs(lines) do
        if row == 1 then
            -- Title line
            vim.api.nvim_buf_add_highlight(buf_id, ns_id, "KeybindTitle", row - 1, 0, -1)
        elseif line:match("^%s*MODE%s+KEYBIND") then
            -- Legend line
            vim.api.nvim_buf_add_highlight(buf_id, ns_id, "KeybindLegend", row - 1, 0, -1)
        elseif line:match("^%s*%[.+%]") then
            -- Group headers like "[LSP]"
            vim.api.nvim_buf_add_highlight(buf_id, ns_id, "KeybindTitle", row - 1, 0, -1)
        end
    end

    --vim.api.nvim_buf_add_highlight(buf_id, ns_id, "KeybindTitle", 0, 0, -1)
    --vim.api.nvim_buf_add_highlight(buf_id, ns_id, "KeybindLegend", 2, 2, -1)

    local height = math.max(4, #lines)
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
