# Norminette-check

This Neovim plugin integrates Norminette, a coding standard verification tool for C projects, with Neovim's quickfix list. It provides commands to check code against Norminette standards and manage the resulting errors in the quickfix list.

## Features

- Run Norminette and display errors in the quickfix list.
- Clear errors from the quickfix list for the current file.
- Clear all errors from the quickfix list.

## Commands
- :NormCheck - Run Norminette on the current file and display errors in the quickfix list.
- :NormClear - Clear Norminette errors from the quickfix list for the current file.
- :NormClearAll - Clear all Norminette errors from the quickfix list.

## Requirements

- `norminette` must be installed and available in your `PATH`.

## Usage
- Run :NormCheck to check the file with Norminette. Any errors will be displayed in the quickfix list.
- To clear errors for the current file, run :NormClear.
- To clear all Norminette errors from the quickfix list, run :NormClearAll.
