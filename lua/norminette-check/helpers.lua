local helper = {}

helper.prompt_for_path = function()
  return vim.fn.input("Path to check: ", vim.fn.getcwd() .. "/", "file")
end

---Get all files in the path recursively
---@param path string: The path we have to walk
---@return table: All files we did find while we walked the path
helper.get_all_files = function(path)
  local file_list = {}

  local is_windows = package.config:sub(1, 1) == "\\"
  local cmd
  if is_windows then
    cmd = 'dir "' .. path .. '" /s /b /a:-d'
  else
    cmd = 'find "' .. path .. '" -type f'
  end

  local handle = io.popen(cmd)
  if handle then
    for file in handle:lines() do
      table.insert(file_list, file)
    end
    handle:close()
  end

  return file_list
end

helper.add_files = function(dict, files)
  if files and #files > 0 then
    for _, file in ipairs(files) do
      table.insert(dict, file)
    end
  end
end

return helper
