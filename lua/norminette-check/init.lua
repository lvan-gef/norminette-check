local qf = require("norminette-check.qf_helpers")
local normi = {}
local uv = vim.uv or vim.loop

---default setting for the plugin
local options = {
  enable = true
}

---Merge user settings with defaults
---@param opts table: The default options
normi.setup = function(opts)
  opts = opts or {}
  for k, v in pairs(options) do
    if opts[k] == nil then
      opts[k] = v
    end
  end

  options = opts
end

local parseNormi = function(path, callback)
  local stdout = vim.loop.new_pipe(false)
  local stderr = vim.loop.new_pipe(false)

  local handle
  ---@diagnostic disable-next-line: missing-fields
  handle, _ = uv.spawn("norminette", {
    args = { path },
    stdio = { nil, stdout, stderr },
  }, function(code, _)
    if stdout then
      stdout:close()
    end

    if stderr then
      stderr:close()
    end

    if handle then
      handle:close()
    end

    if not stdout then
      vim.schedule(function()
        vim.api.nvim_echo({ { "Failed to create stdout pipe for norminette", "ErrorMsg" } }, true, {})
      end)
      callback(nil)
      return
    end

    if not stderr then
      vim.schedule(function()
        vim.api.nvim_echo({ { "Failed to create stderr pipe for norminette", "ErrorMsg" } }, true, {})
      end)
      callback(nil)
      return
    end

    if not handle then
      vim.schedule(function()
        vim.api.nvim_echo({ { "Failed to create a handler for norminette", "ErrorMsg" } }, true, {})
      end)
      callback(nil)
      return
    end

    if code == 127 then
      vim.schedule(function()
        vim.api.nvim_echo({ { "Norminette is not on PATH", "ErrorMsg" } }, true, {})
      end)
      callback(nil)
      return
    end
  end)

  if not stdout then
      vim.schedule(function()
        vim.api.nvim_echo({ { "Failed to create stdout pipe for norminette", "ErrorMsg" } }, true, {})
      end)
      callback(nil)
      return
  end

  local output = {}
  stdout:read_start(function(err, data)
    if err then
      return
    end

    if data then
      table.insert(output, data)
    else
      local errors = {}
      local result = table.concat(output):gsub("\r\n", "\n"):gsub("\r", "\n")

      for line in result:gmatch("[^\n]+") do
        if not line:match("^Error") and not line:match("^Notice") then
          goto continue
        end

        local lnum, col, txt = line:match(".*line: *(%d+), col: *(%d+).*:\t(.*)")
        local lnum_int = tonumber(lnum)
        if lnum_int == nil then
          vim.schedule(function()
            vim.api.nvim_echo({ { "Parser Error: Not a valid line number: " .. line, "ErrorMsg" } }, true, {})
          end)
          callback(nil)
          return
        end

        local col_int = tonumber(col)
        if lnum_int == nil then
          vim.schedule(function()
            vim.api.nvim_echo({ { "Parser Error: Not a valid col number: " .. line, "ErrorMsg" } }, true, {})
          end)
          callback(nil)
          return
        end

        if txt == nil then
          vim.schedule(function()
            vim.api.nvim_echo({ { "Parser Error: No message by a error: " .. line, "ErrorMsg" } }, true, {})
          end)
          callback(nil)
          return
        end

        table.insert(errors, {
          filename = path,
          lnum = lnum_int,
          col = col_int,
          text = txt,
        })

        ::continue::
      end

      vim.schedule(function()
        if #errors == 0 then
          callback({})
        else
          vim.api.nvim_echo({ { "Found " .. #errors .. " Norminette errors", "ErrorMsg" } }, true, {})
          callback(errors)
        end
      end)
    end
  end)
end

---Check for norminette errors in the current buffer
normi.NormiCheck = function()
  if options.enable ~= true then
    return
  end

  local path = vim.api.nvim_buf_get_name(0)
  if path == "" then
    return
  end

  local ext = vim.fn.fnamemodify(path, ":e")
  if ext == "c" or ext == "h" then
    parseNormi(path, function(errors)
      if errors == nil then
        return
      elseif #errors == 0 then
        normi.NormiClear()
        return
      end
      qf.set_errors(errors)
    end)
  end
end

---clear norminette errors from the qf-list given the current buffer
normi.NormiClear = function()
  if options.enable ~= true then
    return
  end

  qf.clear_errors()
end

---Disable norminette-check
normi.NormiDisable = function()
  options.enable = false
end

---Enable norminette-check
normi.NormiEnable = function()
  options.enable = true
end

return normi
