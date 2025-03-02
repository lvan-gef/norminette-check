# Norminette Check

Norminette Check is a simple Neovim plugin that runs the Norminette linter on your C and header files, highlighting errors directly in the quickfix list. It helps you stay compliant with the Norminette style guide effortlessly!

## 🚀 Features
- Runs Norminette on `.c` and `.h` files.
- Displays errors and notices in the quickfix list.
- Supports enabling/disabling checks dynamically.
- Provides user commands for easy usage.
- Uses debouncing to prevent unnecessary multiple runs.

## 📋 Requirements
- Neovim **0.8+**
- [Norminette](https://github.com/42School/norminette) installed and available in your `PATH`
- Lua support enabled in Neovim

## 🛠 Installation
### Using [Lazy.nvim](https://github.com/folke/lazy.nvim)
Add this to your Lazy.nvim plugin list:
```lua
{
  "your-github-username/norminette-check",
  config = function()
    require("norminette-check").setup()
  end,
}
```

## 📖 Usage
### Running Norminette Check
You can manually check for Norminette errors with:
```vim
:NormiCheck
```
This will run the linter on the current buffer and update the quickfix list.

### Clearing Errors
To clear Norminette errors from the quickfix list:
```vim
:NormiClear
```

### Enabling/Disabling the Plugin
- Disable automatic checking:
  ```vim
  :NormiDisable
  ```
- Enable it again:
  ```vim
  :NormiEnable
  ```

### Auto-run on Save
To automatically run Norminette whenever you save a file, add this to your Neovim config:
```lua
vim.api.nvim_create_autocmd("BufWritePost", {
  pattern = {"*.c", "*.h"},
  command = "NormiCheck",
})
```

## 🤝 Contributing
Contributions are welcome! Please feel free to submit a Pull Request.=

## 📜 License
This project is licensed under the MIT License. See [LICENSE](LICENSE) for details.
