# toggle.nvim

A Neovim plugin to create and manage custom toggles for settings and options.

## Features

-   Create simple boolean toggles.
-   Create toggles that cycle through a list of values.
-   Persists toggle states between Neovim sessions.
-   Key-mapping descriptions that update to show the current state.
-   Integration with [mini.clue](https://github.com/echasnovski/mini.clue).

## Installation

### [lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
{
  'jkaraskiewicz/toggle.nvim',
  dependencies = {
    'jkaraskiewicz/utils.nvim',
  },
  config = function()
    require('toggle').setup()
  end,
}
```

## Usage

The plugin is configured through the `setup()` function. You can override the default configuration by passing a table to `setup()`.

### Default Configuration

The plugin comes with two default toggles:

-   **Relative Line Numbers**: Toggles `relativenumber`.
    -   Key: `<leader>tr`
-   **Cursor Style**: Cycles through `block`, `hor20`, and `ver25` cursor styles.
    -   Key: `<leader>tz`

### Customization

Here is an example of how to override the default configuration and add a new toggle:

```lua
require('toggle').setup({
  -- Set a custom prefix for all toggle keymaps
  prefix = '<leader>T', -- defaults to '<leader>t'

  toggles = {
    -- Disable the default relative line numbers toggle
    relative_line_numbers = {
      enabled = false,
    },

    -- Customize the cursor style toggle
    cursor_style = {
      key = 'c', -- change key to <leader>c
      values = { 'block', 'ver25' }, -- only cycle between block and vertical
    },

    -- Add a new toggle for the spell checker
    spell_checker = {
      enabled = true,
      key = 's',
      toggle = function(value)
        vim.opt.spell = value
      end,
      desc = 'Spell checker',
    },
  },
})
```

### Creating Toggles

To create a toggle, you need to add an entry to the `toggles` table in the `setup()` function. Each toggle can have the following properties:

-   `enabled` (boolean, optional, default: `true`): Enable or disable the toggle.
-   `key` (string, required): The key to press after the prefix to activate the toggle.
-   `toggle` (function, required): A function that takes a single `value` argument and applies the new setting.
-   `values` (table, optional, default: `{ false, true }`): A list of values to cycle through.
-   `desc` (string, optional): A description for the toggle, which is used for the keymap description.

## `mini.clue` Integration

This plugin integrates with `mini.clue` to show clues for the available toggles. To enable this, add the following to your `mini.clue` configuration:

```lua
require('mini.clue').setup({
    clues = {
        ...
        require('toggle').clues(),
    }
})
```

## License

This plugin is licensed under the terms of the LICENSE file.
