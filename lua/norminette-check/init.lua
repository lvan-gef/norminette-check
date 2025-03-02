local qf = require("norminette-check.qf_helpers")
local uv = vim.uv or vim.loop
local normi = {}

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

---Handle errors
---@param msg string: The message that should be printed
---@param callback function: Function to call add the end
---@param value table | nil: The value to use for the callback
local function handle_error(msg, callback, value)
  vim.schedule(function()
    vim.notify(msg, vim.log.levels.ERROR, nil);
  end)

  if callback then
    vim.schedule(function()
      callback(value or {})
    end)
  end
end

---Run's norminette and parse it
---@param path string: Path to the file you want to check
---@param callback function: function to call add the end
local parseNormi = function(path, callback)
  local stdout, _, _ = uv.new_pipe(false)
  local stderr, _, _ = uv.new_pipe(false)

  if not stdout or not stderr then
    handle_error("Failed to create pipes for norminette", callback, nil)
    return
  end

  local handle
  ---@diagnostic disable-next-line: missing-fields
  handle, _ = uv.spawn("norminette", {
    args = { path },
    stdio = { nil, stdout, stderr },
  }, function(code, _)
    stdout:close()
    stderr:close()
    handle:close()

    if code == 127 then
      handle_error("Norminette is not on PATH", callback, nil)
      return
    end
  end)

  if not handle then
    handle_error("Failed to create a handler for norminette", callback, nil)
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
        if line:match("^Error") or line:match("^Notice") then
          local lnum, col, txt = line:match(".*line: *(%d+), col: *(%d+).*:\t(.*)")
          if not lnum or not col or not txt then
            handle_error("Parse Error: Invalid format: " .. line, callback, nil)
            return
          end

          local lnum_int = tonumber(lnum)
          if lnum_int == nil then
            handle_error("Parser Error: Not a valid line number: " .. line, callback, nil)
            return
          end

          local col_int = tonumber(col)
          if col_int == nil then
            handle_error("Parser Error: Not a valid col number: " .. line, callback, nil)
            return
          end

          if txt == nil then
            handle_error("Parser Error: No message by a error: " .. line, callback, nil)
            return
          end

          table.insert(errors, {
            filename = path,
            lnum = lnum_int,
            col = col_int,
            text = txt,
          })
        end
      end

      if #errors == 0 then
        callback({})
      else
        handle_error("Found " .. #errors .. " Norminette errors", callback, errors)
      end
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
