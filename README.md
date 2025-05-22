# Keybind Tracker for Neovim

Map keybindings and track them for display in a floating window (so you don't forget what they are!).

![Keybind Tracker Screenshot](./screenshot.png)

## Features

* Toggleable floating window listing keybindings
* Dynamically updates as keybindings are registered
* Simple API: wrap your mappings using `map()` to track them

## Installation

Using [Lazy.nvim](https://github.com/folke/lazy.nvim):

```lua
{
  "yuri-rage/nvim-keybind-tracker",
  event = "VeryLazy",
  config = function()
    require("keybind-tracker").setup({
      -- optional settings (these are the defaults)
      toggle_key = "<leader>kb", -- replace with desired key
      toggle_desc = "Toggle keybinds window", -- replace with desired description
    })

    -- add additional keybinds as desired
    -- (or in init.lua using the same syntax)
    local map = require("keybind-tracker").map
    map("n", "H", "gT", { desc = "gT (previous tab)" })
    map("n", "L", "gt", { desc = "gt (next tab)" })
    map("n", "<leader>ff", require("telescope.builtin").find_files, { desc = "Find files" })
  end,
}
```

## Author's Configuration

I use the following `.config/nvim/lua/plugins/keybinds.lua` file with Lazy.nvim:
```lua
return {
    "yuri-rage/nvim-keybind-tracker",
    event = "VeryLazy",
    config = function()
        require("keybind-tracker").setup({})
        local map = require("keybind-tracker").map

        -- Tab navigation
        map("n", "H", "gT", { desc = "gT (previous tab)" })
        map("n", "L", "gt", { desc = "gt (next tab)" })

        -- Neo-tree
        map("n", "<C-n>", ":Neotree filesystem toggle left<CR>", { desc = "Toggle Neotree" })

        -- Telescope
        local builtin = require("telescope.builtin")
        map("n", "<C-p>", builtin.find_files, { desc = "Find files (Telescope)" })
        map("n", "<leader>fg", builtin.live_grep, { desc = "Live grep" })

        -- LSP
        map("n", "K", vim.lsp.buf.hover, { desc = "Inspect symbol under cursor (LSP hover)" })
        map("n", "<leader>gd", vim.lsp.buf.definition, { desc = "Go to definition" })
        map("n", "<leader>gr", vim.lsp.buf.references, { desc = "Find references" })
        map("n", "<leader>ca", vim.lsp.buf.code_action, { desc = "Code action" })
        map("n", "<leader>gf", vim.lsp.buf.format, { desc = "Format file" })

        -- Gitsigns
        map("n", "<leader>gp", ":Gitsigns preview_hunk<CR>", { desc = "Git: preview hunk" })
        map("n", "<leader>gt", ":Gitsigns toggle_current_line_blame<CR>", { desc = "Git: toggle blame" })
    end,
}
```
