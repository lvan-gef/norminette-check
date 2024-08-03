local qf = require("norminette-check.qf_helpers")
local plug_id = "norminette"
local M = {}

---Run's norminette and return the errors
---@param path string
---@return table | nil
local getErrors = function(path)
	local output = vim.fn.system("norminette " .. vim.fn.shellescape(path) .. " 2>&1")
	local status = vim.v.shell_error

	if status == 127 then
		vim.api.nvim_echo({ { "Norminette is not on PATH", "ErrorMsg" } }, true, {})
		return nil
	end

	output = output:gsub("\r\n", "\n"):gsub("\r", "\n")
	local errors = {}
	for line in output:gmatch("[^\n]+") do
		if not line:match("^Error") and not line:match("^Notice") then
			goto continue
		end

		local lnum, col, txt = line:match(".*line: *(%d+), col: *(%d+).*:\t(.*)")

		local lnum_int = tonumber(lnum)
		if lnum_int == nil then
			vim.api.nvim_echo({ { "Not a valid line number: " .. line, "ErrorMsg" } }, true, {})
			return nil
		end

		local col_int = tonumber(col)
		if lnum_int == nil then
			vim.api.nvim_echo({ { "Not a valid col number: " .. line, "ErrorMsg" } }, true, {})
			return nil
		end

		if txt == nil then
			vim.api.nvim_echo({ { "No message by a error: " .. line, "ErrorMsg" } }, true, {})
			return nil
		end

		table.insert(errors, {
			filename = path,
			lnum = lnum_int,
			col = col_int,
			text = txt,
		})

		::continue::
	end

	if status == 0 and #errors == 0 then
		vim.api.nvim_echo({ { "Norminette is Happy", "InfoMsg" } }, true, {})
		return nil
	end

	if #errors == 0 then
		vim.api.nvim_echo({ { "Norminette exit code: " .. status .. ".\nBut we have " .. #errors .. "error's", "ErrorMsg" } }, true, {})
		return nil
	end

	return errors
end

---run's norminette and add errors to the quickfix list
M.NormCheck = function()
	local buffnr = vim.api.nvim_get_current_buf()
	local path = vim.api.nvim_buf_get_name(buffnr)
	if path == "" then
		return
	end
	local name = vim.fn.fnamemodify(path, ":t:r")

	if name == nil then
		return
	end

	local errors = getErrors(path)
	if errors == nil then
		M.NormClear()
		return
	end

	qf.append_errors(errors, plug_id, name)
end

---clear errors from the qf-list given the filename
M.NormClear = function()
	local buffnr = vim.api.nvim_get_current_buf()
	local path = vim.api.nvim_buf_get_name(buffnr)
	if path == "" then
		return
	end
	local name = vim.fn.fnamemodify(path, ":t:r")

	if name == nil then
		return
	end

	qf.clear_errors(plug_id, name)
end

---clear all errors from the qf-list
M.NormClearAll = function()
	qf.clear_all_errors(plug_id)
end

return M
