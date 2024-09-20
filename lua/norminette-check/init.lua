local qf = require("norminette-check.qf_helpers")
local plug_id = "norminette"
local normi = {}

--- default setting for the plugin
local options = {
	enable = true
}

--- Merge user settings with defaults
--- @param opts table  The default options
normi.setup = function(opts)
	opts = opts or {}
	for k, v in pairs(options) do
		if opts[k] == nil then
			opts[k] = v
		end
	end

	options = opts
end

--- Run's norminette and parse norminette
--- @param path string  Path to the file you want to check
--- @return table | nil
local parseNormi = function(path)
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
			vim.api.nvim_echo({ { "Parser Error: Not a valid line number: " .. line, "ErrorMsg" } }, true, {})
			return nil
		end

		local col_int = tonumber(col)
		if lnum_int == nil then
			vim.api.nvim_echo({ { "Parser Error: Not a valid col number: " .. line, "ErrorMsg" } }, true, {})
			return nil
		end

		if txt == nil then
			vim.api.nvim_echo({ { "Parser Error: No message by a error: " .. line, "ErrorMsg" } }, true, {})
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

	if status == 0 and #errors ~= 0 then
		vim.api.nvim_echo(
			{ { "Norminette exit code: " .. status .. ".\nBut we have " .. #errors .. "error's", "ErrorMsg" } }, true, {})
		return nil
	end

	return errors
end

--- Check for norminette errors in the current buffer
normi.NormiCheck = function()
	if options.enable ~= true then
		return
	end

	local path = vim.api.nvim_buf_get_name(0)
	if path == "" then
		return
	end

	local name = vim.fn.fnamemodify(path, ":t:r")
	if name == nil then
		return
	end

	local ext = vim.fn.fnamemodify(path, ":e")
	if ext == nil then
		return
	end

	if ext == "c" or ext == "h" then
		local errors = parseNormi(path)
		if errors == nil then
			normi.NormiClear()
			return
		end

		qf.append_errors(errors, plug_id, name)
	end
end

--- clear norminette errors from the qf-list given the current buffer
normi.NormiClear = function()
	if options.enable ~= true then
		return
	end

	local path = vim.api.nvim_buf_get_name(0)
	if path == "" then
		return
	end

	local name = vim.fn.fnamemodify(path, ":t:r")
	if name == nil then
		return
	end
end

--- clear all norminette errors from the qf-list
normi.NormiClearAll = function()
	if options.enable ~= true then
		return
	end

	qf.clear_all_errors(plug_id)
end

--- Disable norminette-check
normi.NormiDisable = function()
	options.enable = false
end

--- Enable norminette-check
normi.NormiEnable = function()
	options.enable = true
end

return normi
