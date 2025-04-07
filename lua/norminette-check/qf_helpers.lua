local qf = {}

---Set the errors to the qf-list
---@param err_list table : List of error entries to append
qf.set_errors = function(err_list)
  local new_qflist = {}

  for _, entry in ipairs(err_list) do
    entry.text = entry.text
    table.insert(new_qflist, entry)
  end

  vim.fn.setqflist(new_qflist, "r")
end

---Clear errors from the quickfix list given the plugin id
qf.clear_errors = function()
  vim.schedule(function ()
    vim.fn.setqflist({}, "r")
  end)
end

return qf
