local qf = require("norminette-check.qf_helpers")
local plug_id = "norminette"
local M = {}

---Run's norminette and return the errors
--- @param path string
--- @return string | nil
local getErrors = function(path)
	local output = vim.fn.system("norminette " .. vim.fn.shellescape(path))
	if vim.v.shell_error == 0 then
		return ""
	end

	if vim.v.shell_error == 127 then
		vim.api.nvim_echo({ { "Norminette is not on PATH", "ErrorMsg" } }, true, {})
		return
	end

	local command = "echo "
		.. vim.fn.shellescape(output)
		.. " | grep -E '^(Error|Notice)' | uniq | sed -n 's/.*line: *\\([0-9]*\\), col: *\\([0-9]*\\).*:\\t\\(.*\\)/\\1:\\2:\\3/p'"
	output = vim.fn.system(command)
	if vim.v.shell_error ~= 0 then
		vim.api.nvim_echo({ { "Something went wrong while parsing the output...", "ErrorMsg" } }, true, {})
		return nil
	end

	return output
end

--- run's norminette and add errors to the quickfix list
M.NormCheck = function()
	local buffnr = vim.api.nvim_get_current_buf()
	local path = vim.api.nvim_buf_get_name(buffnr)
	local name = vim.fn.fnamemodify(path, ":t:r")

	if name == nil then
		return
	end

	local result = getErrors(path)
	if result == nil then
		M.NormClear()
		return
	end

	if result == "" then
		M.NormClear()
		vim.api.nvim_echo({ { "Norminette is Happy", "InfoMsg" } }, true, {})
		return
	end

	local tmp_errors = {}
	for line in result:gmatch("[^\r\n]+") do
		local lnum, col, msg = line:match("(%d+):(%d+):(.+)")
		if lnum and col and msg then
			table.insert(tmp_errors, { filename = path, lnum = tonumber(lnum), col = tonumber(col), text = msg })
		end
	end

	qf.append_errors(tmp_errors, plug_id, name)
end

--- clear errors from the qf-list given the filename
M.NormClear = function()
	local buffnr = vim.api.nvim_get_current_buf()
	local path = vim.api.nvim_buf_get_name(buffnr)
	local name = vim.fn.fnamemodify(path, ":t"):match("(.+)%..+$")

	if name == nil then
		return
	end

	qf.clear_errors(plug_id, name)
end

--- clear all errors from the qf-list
M.NormAllClear = function()
	qf.clear_all_errors(plug_id)
end

-- user commands
vim.api.nvim_create_user_command("NormCheck", M.NormCheck, {})
vim.api.nvim_create_user_command("NormClear", M.NormClear, {})
vim.api.nvim_create_user_command("NormClearAll", M.NormAllClear, {})

return M
