-- Prevent the plugin from being loaded more than once
if vim.g.loaded_codamnormcheck then
    return
end

-- check if norminette can called at all
local handle = io.popen("norminette")
if not handle then
    vim.api.nvim_err_writeln("Failed to execute 'norminette'.")
    return
end

-- read output of the command, and check it was succesfull
local result = handle:read("*a")
handle:close()
if not result or result == "" or result:find("command not found") then
    vim.api.nvim_echo({{"Norminette is not installed or not in PATH.", "ErrorMsg"}}, true, {})
    return
end

-- Set the flag indicating that Norminette is loaded and available
vim.g.loaded_codamnormcheck = 1
