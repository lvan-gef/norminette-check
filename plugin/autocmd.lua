vim.api.nvim_create_user_command("NormiCheck", function()
  require("norminette-check").NormiCheck()
end, {})

vim.api.nvim_create_user_command("NormiClear", function()
  require("norminette-check").NormiClear()
end, {})

vim.api.nvim_create_user_command("NormiEnable", function()
  require("norminette-check").NormiEnable()
end, {})

vim.api.nvim_create_user_command("NormiDisable", function()
  require("norminette-check").NormiDisable()
end, {})
