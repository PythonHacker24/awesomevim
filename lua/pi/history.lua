--- Persistent index of closed/known sessions (metadata only; conversation
--- content lives in pi's own .jsonl session files).
local M = {}

local function path()
  return require("pi.config").get().history_file
end

local function load()
  local f = io.open(path(), "r")
  if not f then return { sessions = {} } end
  local content = f:read("*a")
  f:close()
  local ok, data = pcall(vim.json.decode, content)
  if ok and type(data) == "table" and type(data.sessions) == "table" then
    return data
  end
  return { sessions = {} }
end

local function save(data)
  local p = path()
  vim.fn.mkdir(vim.fn.fnamemodify(p, ":h"), "p")
  local f = io.open(p, "w")
  if not f then return end
  f:write(vim.json.encode(data))
  f:close()
end

--- meta: { name, session_file, mode, cwd, model, last_used }
function M.add(meta)
  if not meta.session_file then return end
  local data = load()
  for i = #data.sessions, 1, -1 do
    if data.sessions[i].session_file == meta.session_file then
      table.remove(data.sessions, i)
    end
  end
  table.insert(data.sessions, 1, meta)
  -- cap history size
  while #data.sessions > 100 do
    table.remove(data.sessions)
  end
  save(data)
end

function M.list()
  local sessions = load().sessions
  -- drop entries whose session file no longer exists
  return vim.tbl_filter(function(s)
    return s.session_file and vim.fn.filereadable(s.session_file) == 1
  end, sessions)
end

return M
