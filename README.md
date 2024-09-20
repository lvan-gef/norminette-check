# Norminette Checker for Neovim

## Overview

This plugin integrates Norminette, the coding style checker used in 42 schools, into your Neovim. It allows you to run Norminette on your .c or .h file without leaving your editor, displaying results conveniently in Neovim's quickfix list.

## Features

- Execute Norminette on the current buffer with a simple command
- View Norminette errors directly in Neovim's quickfix list
- Clear Norminette errors for the current buffer or all buffers
- Optional automatic checks on file save
- Enable or Disable the checker

## Requirements

- Neovim 0.9.0 or later
- Norminette installed and accessible in your PATH

## Installation

Using [lazy.nvim](https://github.com/folke/lazy.nvim):

```lua
{
  'lvan-gef/norminette-checker',
  config = function()
    require('norminette-checker').setup()
  end
}
```

## Usage

The plugin provides the following Lua functions:

- `require('norminette-checker').NormiCheck()`   : Run Norminette on the current buffer
- `require('norminette-checker').NormiClear()`   : Clear Norminette errors for the current buffer
- `require('norminette-checker').NormiClearAll()`: Clear all Norminette errors
- `require('norminette-checker').NormiEnable()`  : Enable checker
- `require('norminette-checker').NormiDisable()` : Disable checker

You can map these functions to keyboard shortcuts in your Neovim configuration:

```lua
vim.api.nvim_set_keymap('n', '<leader>nc', "<cmd>lua require('norminette-checker').NormiCheck()<CR>", { noremap = true, silent = true, desc = "[N]ormi [C]heck" }
vim.api.nvim_set_keymap('n', '<leader>nr', "<cmd>lua require('norminette-checker').NormiClear()<CR>", { noremap = true, silent = true, desc = "[N]ormi [R]emove" }
vim.api.nvim_set_keymap('n', '<leader>nra', "<cmd>lua require('norminette-checker').NormiClearAll()<CR>", { noremap = true, silent = true, desc = "[N]ormi [R]emove [A]ll" }
vim.api.nvim_set_keymap('n', '<leader>ne', "<cmd>lua require('norminette-checker').NormiEnable()<CR>", { noremap = true, silent = true, desc = "[N]ormi [E]nable" }
vim.api.nvim_set_keymap('n', '<leader>nd', "<cmd>lua require('norminette-checker').NormiDisable()<CR>", { noremap = true, silent = true, desc = "[N]ormi [D]isable" }
```

## Autorun on Save

To automatically run Norminette when you save a file, add the following to your Neovim configuration:

```lua
vim.api.nvim_create_autocmd("BufWritePost", {
  pattern = {"*.c", "*.h"},
  callback = function()
    require('norminette-checker').NormiCheck()
  end,
})
```

This will run the Norminette every time you save a `.c` or `.h` file.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.
