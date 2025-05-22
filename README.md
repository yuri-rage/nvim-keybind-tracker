# Keybind Tracker for Neovim

Map and display keybindings in a floating window.

![Keybind Tracker Screenshot](./screenshot.png)

## Features

* Toggleable floating window listing keybindings
* Dynamically updates mappings are registered
* Simple API: wrap your mappings using `map()` to track them
* Configurable toggle keybinding via `setup()`

## Installation

Using [Lazy.nvim](https://github.com/folke/lazy.nvim):

```lua
{
  "yuri-rage/nvim-keybind-tracker",
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
