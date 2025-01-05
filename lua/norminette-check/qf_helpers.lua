local qf = {}
local plug_id = "norminette"

---The plugin id format
---@return string: The pattern
local function get_pattern()
  return "%[" .. plug_id .. "%]"
end

---Set the errors to the qf-list
---@param err_list table : List of error entries to append
qf.set_errors = function(err_list)
  local new_qflist = {}

  for _, entry in ipairs(err_list) do
    entry.text = entry.text .. " " .. get_pattern():gsub("%%", "")
    table.insert(new_qflist, entry)
  end

  vim.fn.setqflist(new_qflist, "r")
end

---Clear errors from the quickfix list given the plugin id
qf.clear_errors = function()
  local cur_qflist = vim.fn.getqflist()
  local new_qflist = {}
  local pattern = "%s" .. get_pattern() .. "$"

  for _, entry in ipairs(cur_qflist) do
    if not entry.text:match(pattern) then
      table.insert(new_qflist, entry)
    end
  end

  vim.fn.setqflist(new_qflist, "r")
end

return qf
