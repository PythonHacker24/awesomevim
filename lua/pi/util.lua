local M = {}

function M.notify(msg, level)
  vim.notify("[pi] " .. msg, level or vim.log.levels.INFO)
end

function M.err(msg)
  M.notify(msg, vim.log.levels.ERROR)
end

function M.trim(s)
  return (s:gsub("^%s+", ""):gsub("%s+$", ""))
end

--- Extract plain text from a pi content-block array ({type="text", text=...}, ...)
function M.content_text(content)
  if content == nil then return "" end
  if type(content) == "string" then return content end
  local parts = {}
  for _, block in ipairs(content) do
    if type(block) == "table" and block.type == "text" and block.text then
      parts[#parts + 1] = block.text
    end
  end
  return table.concat(parts, "\n")
end

--- Short one-line summary of tool args for display
function M.args_summary(name, args)
  if type(args) ~= "table" then return "" end
  if name == "bash" and args.command then return args.command end
  if args.path then return args.path end
  if args.pattern then return args.pattern end
  local ok, json = pcall(vim.json.encode, args)
  if not ok then return "" end
  if #json > 80 then json = json:sub(1, 77) .. "..." end
  return json
end

return M
