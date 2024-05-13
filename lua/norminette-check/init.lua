vim.fn.system("norminette --version")
if vim.v.shell_error ~= 0 then
	vim.api.nvim_echo({{"Norminette is not on PATH", "ErrorMsg"}}, true, {})
	return
end

local utils = require("norminette-check.utils")
local M = {}

-- set global group and sign
local norm_check_group = "CodamNormCheckGroup"
local norm_check_error = "CodamNormCheckError"
vim.fn.sign_define(norm_check_error, {text = ">>", texthl = "Error", linehl = "", numhl = ""})

local getErrors = function(path)
	local output = vim.fn.system("norminette " .. vim.fn.shellescape(path))
    if vim.v.shell_error == 0 then
		return ""
	end

	local command = "echo " .. vim.fn.shellescape(output) .. " | grep -E '^(Error|Notice)' | uniq | sed -n 's/.*line: *\\([0-9]*\\), col: *\\([0-9]*\\).*:\\t\\(.*\\)/\\1:\\2:\\3/p'"
	output = vim.fn.system(command)
	if vim.v.shell_error ~= 0 then
		vim.api.nvim_echo({{"Something went wrong while parsing the output...", "ErrorMsg"}}, true, {})
		return nil
	end

	return output
end


local errors = {}

-- run's norminette and add the result to neovim
M.NormCheck = function ()
	local buffnr = vim.api.nvim_get_current_buf()
	local path = vim.api.nvim_buf_get_name(buffnr)

	local result = getErrors(path)
	if result == nil then
		return
	end

	if result == "" then
		vim.fn.sign_unplace(norm_check_group)
		vim.api.nvim_echo({{"Norminette is Happy", "InfoMsg"}}, true, {})
		return
	end

	local tmp_errors = {}
	for line in result:gmatch("[^\r\n]+") do
		local lnum, col, msg = line:match("(%d+):(%d+):(.+)")
		if lnum and col and msg then
			table.insert(tmp_errors, {lnum = tonumber(lnum), col = tonumber(col), text = msg, buffnr = buffnr})
		end
	end
	errors[buffnr] = utils.uniqTables(tmp_errors, errors[buffnr])

	vim.fn.sign_unplace(norm_check_group)
	for _, err in ipairs(errors[buffnr]) do
		vim.fn.sign_place(0, norm_check_group, norm_check_error, err.buffnr, {
			lnum = err.lnum,
			priority = 100
		})
	end
end

-- clear the current sign list
M.NormClear = function ()
	vim.fn.sign_unplace(norm_check_group)
end

-- echo the message backout
M.NormShow = function ()
	local buffnr = vim.api.nvim_get_current_buf()
	local row, _ = unpack(vim.api.nvim_win_get_cursor(0))

	if errors[buffnr] == nil then
		return
	end

	for _, err in ipairs(errors[buffnr]) do
		if err.lnum == row and err.buffnr == buffnr then
			vim.api.nvim_echo({{err.text, "InfoMsg"}}, true, {})
			break
		end
	end
end

return M
