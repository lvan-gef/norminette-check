local qf = {}

--- Check if error is in qflist
---@param entry   table  The new errors
---@param qflist  table  The current qf-list
---@param plug_id string The unique identifier for the plugin.
---@return boolean
local function entry_exists(entry, qflist, plug_id)
	for _, qf_entry in ipairs(qflist) do
		if
			qf_entry.filename == entry.filename
			and qf_entry.lnum == entry.lnum
			and qf_entry.col == entry.col
			and string.match(qf_entry.text, plug_id .. "%]$")
		then
			return true
		end
	end

	return false
end

--- Append errors to the quickfix list with a unique plugin identifier.
---@param err_list table  A list of error entries to append.
---@param plug_id  string The unique identifier for the plugin.
---@param name     string The filename without extension
qf.append_errors = function(err_list, plug_id, name)
	local cur_qflist = vim.fn.getqflist()
	local new_qflist = {}

	for _, entry in ipairs(cur_qflist) do
		if not string.match(entry.text, plug_id .. "%]$") then
			table.insert(new_qflist, entry)
		end
	end

	for _, entry in ipairs(err_list) do
		if not entry_exists(entry, new_qflist, plug_id) then
			entry.text = entry.text .. " [" .. name .. "_" .. plug_id .. "]"
			table.insert(new_qflist, entry)
		end
	end

	vim.fn.setqflist(new_qflist, "r")
end

--- Clear errors from the quickfix list given the filename
---@param plug_id string The unique identifier for the plugin.
---@param name    string The filename without extension
qf.clear_errors = function(plug_id, name)
	local cur_qflist = vim.fn.getqflist()
	local new_qflist = {}

	for _, entry in ipairs(cur_qflist) do
		if not string.match(entry.text, name .. "_" .. plug_id .. "]$") then
			table.insert(new_qflist, entry)
		end
	end

	vim.fn.setqflist(new_qflist, "r")
end

--- Clear all errors from the quickfix list
---@param plug_id string The unique identifier for the plugin.
qf.clear_all_errors = function(plug_id)
	local cur_qflist = vim.fn.getqflist()
	local new_qflist = {}

	for _, entry in ipairs(cur_qflist) do
		if not string.match(entry.text, plug_id .. "]$") then
			table.insert(new_qflist, entry)
		end
	end

	vim.fn.setqflist(new_qflist, "r")
end

return qf
