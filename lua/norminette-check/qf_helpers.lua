local qf = {}

--- Append errors to the quickfix list with a unique plugin identifier.
--- @param err_list table  A list of error entries to append.
--- @param plug_id  string The unique identifier for the plugin.
--- @param name     string The filename without extension
qf.append_errors = function(err_list, plug_id, name)
	qf.clear_errors(plug_id, name)

	for _, entry in ipairs(err_list) do
		entry.text = entry.text .. " [" .. name .. "_" .. plug_id .. "]"
		vim.fn.setqflist({ entry }, "a")
	end
end

--- Clear errors from the quickfix list given the filename
--- @param plug_id string The unique identifier for the plugin.
--- @param name    string The filename without extension
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
--- @param plug_id string The unique identifier for the plugin.
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
