# Norminette-check

Norminette-check is a Neovim plugin that integrates `norminette` to check for norm errors in your code. It highlights errors directly in the editor and provides commands to manage and view these errors.

## Features

- Run `norminette` on the current buffer.
- Highlight norm errors in the code.
- Display error messages in the Neovim command line.

## Requirements

- Neovim 0.5.0 or later.
- `norminette` must be installed and available in your `PATH`.

## Usage
- The plugin provides the following commands:

- :NormCheck - Run norminette on the current buffer and highlight errors.
- :NormClear - Clear all norm error highlights.
- :NormShow - Show the norm error message for the current line in the command line.
