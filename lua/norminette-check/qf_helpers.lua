local qf = {}

---The format add the end of the line
---@param plug_id string: The unique identifier for the plugin
---@return        string: The pattern
local function get_pattern(plug_id)
  return " [" .. plug_id .. "]"
end

---Append errors to the quickfix list with a unique plugin identifier.
---@param plug_id  string: The unique identifier for the plugin
---@param err_list table : List of error entries to append
qf.set_errors = function(plug_id, err_list)
  local new_qflist = {}

  for _, entry in ipairs(err_list) do
    entry.text = entry.text .. get_pattern(plug_id)
    table.insert(new_qflist, entry)
  end

  vim.fn.setqflist(new_qflist, "r")
end

---Clear errors from the quickfix list given the filename
---@param plug_id string: The unique identifier for the plugin.
qf.clear_errors = function(plug_id)
  local cur_qflist = vim.fn.getqflist()
  local new_qflist = {}

  for _, entry in ipairs(cur_qflist) do
    if not string.match(entry.text, get_pattern(plug_id)) then
      table.insert(new_qflist, entry)
    end
  end

  vim.fn.setqflist(new_qflist, "r")
end

return qf
