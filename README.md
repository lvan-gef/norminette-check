# Norminette-check

This Neovim plugin integrates Norminette, a coding standard verification tool for C projects, with Neovim's quickfix list. It provides commands to check code against Norminette standards and manage the resulting errors in the quickfix list.

## Requirements

- `norminette` must be installed and available in your `PATH`.

## Commands
- :NormiCheck - Run Norminette on the current file and display errors in the quickfix list.
- :NormiClear - Clear Norminette errors from the quickfix list for the current file.
- :NormiClearAll - Clear all Norminette errors from the quickfix list.
