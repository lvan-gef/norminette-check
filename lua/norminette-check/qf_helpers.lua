local qf = {}
local plug_id = "[norminette]"

---Set the errors to the qf-list
---@param err_list table : List of error entries to append
qf.set_errors = function(err_list)
  local new_qflist = {}

  for _, entry in ipairs(err_list) do
    entry.text = entry.text .. " " .. plug_id
    table.insert(new_qflist, entry)
  end

  vim.fn.setqflist(new_qflist, "r")
end

---Clear errors from the quickfix list given the plugin id
qf.clear_errors = function()
  local cur_qflist = vim.fn.getqflist()
  local new_qflist = {}
  local suffix = " " .. plug_id

  for _, entry in ipairs(cur_qflist) do
    local text_len = #entry.text
    local suffix_len = #suffix
    if text_len < suffix_len or entry.text:sub(-suffix_len) ~= suffix then
      table.insert(new_qflist, entry)
    end
  end

  vim.fn.setqflist(new_qflist, "r")
end

return qf
