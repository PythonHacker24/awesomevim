--- JSONL RPC client for a `pi --mode rpc` subprocess.
--- One client per session/tab. Strict framing: split on \n only, strip \r.
local util = require("pi.util")

local Client = {}
Client.__index = Client

local M = {}

--- opts: { cmd = {list}, cwd = string, on_event = fn(ev), on_exit = fn(code) }
function M.new(opts)
  local self = setmetatable({}, Client)
  self.pending = {} -- id -> callback
  self.next_id = 0
  self._partial = ""
  self.on_event = opts.on_event
  self.on_exit = opts.on_exit
  self.dead = false

  self.job = vim.fn.jobstart(opts.cmd, {
    cwd = opts.cwd,
    on_stdout = function(_, data)
      self:_on_stdout(data)
    end,
    on_stderr = function(_, data)
      -- keep last stderr lines for diagnostics
      for _, l in ipairs(data) do
        if l ~= "" then self._last_stderr = l end
      end
    end,
    on_exit = function(_, code)
      self.dead = true
      if self.on_exit then
        vim.schedule(function()
          self.on_exit(code, self._last_stderr)
        end)
      end
    end,
  })

  if self.job <= 0 then
    self.dead = true
    util.err("failed to spawn: " .. table.concat(opts.cmd, " "))
    return nil
  end
  return self
end

-- jobstart streams data as a list where the first element continues the
-- previous partial line and the last element is a new partial line.
function Client:_on_stdout(data)
  if not data or #data == 0 then return end
  data[1] = self._partial .. data[1]
  self._partial = table.remove(data)
  for _, line in ipairs(data) do
    if line:sub(-1) == "\r" then line = line:sub(1, -2) end
    if line ~= "" then self:_on_line(line) end
  end
end

function Client:_on_line(line)
  local ok, msg = pcall(vim.json.decode, line)
  if not ok or type(msg) ~= "table" then return end
  if msg.type == "response" and msg.id ~= nil and self.pending[msg.id] then
    local cb = self.pending[msg.id]
    self.pending[msg.id] = nil
    vim.schedule(function() cb(msg) end)
  elseif self.on_event then
    vim.schedule(function() self.on_event(msg) end)
  end
end

--- Fire-and-forget command.
function Client:send(cmd)
  if self.dead then return false end
  local ok, encoded = pcall(vim.json.encode, cmd)
  if not ok then return false end
  vim.fn.chansend(self.job, encoded .. "\n")
  return true
end

--- Command with response callback.
function Client:request(cmd, cb)
  if self.dead then
    if cb then cb({ success = false, error = "pi process is not running" }) end
    return
  end
  self.next_id = self.next_id + 1
  local id = "nvim-" .. self.next_id
  cmd.id = id
  self.pending[id] = cb or function() end
  self:send(cmd)
end

--- Graceful shutdown: close stdin, kill after a timeout if still alive.
function Client:shutdown()
  if self.dead then return end
  pcall(vim.fn.chanclose, self.job, "stdin")
  local job = self.job
  vim.defer_fn(function()
    pcall(vim.fn.jobstop, job)
  end, 1500)
end

return M
