--- Session: one tab = one independent `pi --mode rpc` subprocess.
local rpc = require("pi.rpc")
local util = require("pi.util")

local Session = {}
Session.__index = Session

local M = {}
local counter = 0

--- opts: { name?, mode?, cfg, cwd?, session_path?, on_update = fn(session) }
function M.new(opts)
  counter = counter + 1
  local self = setmetatable({}, Session)
  self.id = counter
  self.name = opts.name or ("chat-" .. counter)
  self.mode = opts.mode or opts.cfg.default_mode
  self.cfg = opts.cfg
  self.cwd = opts.cwd or opts.cfg.cwd or vim.fn.getcwd()
  self.on_update = opts.on_update

  self.transcript = {} -- render entries
  self.tools_by_id = {} -- toolCallId -> tool entry
  self.streaming = false
  self.unread = false
  self.dead = false
  self.status = nil -- extension setStatus text
  self.model = nil
  self.thinking = nil
  self.session_file = opts.session_path
  self._resume = opts.session_path ~= nil

  local cmd = { self.cfg.cmd, "--mode", "rpc", "--name", self.name }
  if opts.session_path then
    vim.list_extend(cmd, { "--session", opts.session_path })
  end
  if self.cfg.session_dir then
    vim.list_extend(cmd, { "--session-dir", self.cfg.session_dir })
  end
  if self.cfg.default_model and not opts.session_path then
    vim.list_extend(cmd, { "--model", self.cfg.default_model })
  end
  if self.mode == "plan" then
    vim.list_extend(cmd, {
      "--tools", self.cfg.plan_tools,
      "--append-system-prompt", self.cfg.plan_prompt,
    })
  end
  if self.cfg.agent_context then
    local ctx = self.cfg.agent_context
    if ctx == true then ctx = require("pi.context").text end
    vim.list_extend(cmd, { "--append-system-prompt", ctx })
  end

  self.rpc = rpc.new({
    cmd = cmd,
    cwd = self.cwd,
    on_event = function(ev) self:_on_event(ev) end,
    on_exit = function(code, stderr)
      self.dead = true
      self.streaming = false
      if not self._closing then
        local msg = ("pi process exited (code %s)"):format(code)
        if stderr then msg = msg .. ": " .. stderr end
        self:_push({ kind = "error", text = msg })
      end
      self:_changed()
    end,
  })
  if not self.rpc then
    self.dead = true
    return self
  end

  self.rpc:request({ type = "get_state" }, function(res)
    if res.success and res.data then
      self.model = res.data.model
      self.thinking = res.data.thinkingLevel
      self.session_file = res.data.sessionFile or self.session_file
      if self._resume then
        self:_rebuild()
      else
        self:_changed()
      end
    elseif res.error then
      self:_push({ kind = "error", text = res.error })
    end
  end)

  return self
end

function Session:_push(entry)
  table.insert(self.transcript, entry)
  self:_changed()
end

function Session:_changed()
  if self.on_update then self.on_update(self) end
end

--- Send a user prompt. Steers automatically if the agent is streaming.
function Session:prompt(text)
  if self.dead then
    util.err("this tab's pi process is dead; reopen it from history")
    return
  end
  local steered = self.streaming
  self:_push({ kind = "user", text = text, steered = steered })
  local cmd = { type = "prompt", message = text }
  if steered then cmd.streamingBehavior = "steer" end
  self.rpc:request(cmd, function(res)
    if not res.success then
      self:_push({ kind = "error", text = res.error or "prompt rejected" })
    end
  end)
end

function Session:abort()
  if self.dead then return end
  self.rpc:send({ type = "abort" })
end

function Session:set_model(provider, model_id)
  self.rpc:request(
    { type = "set_model", provider = provider, modelId = model_id },
    function(res)
      if res.success then
        self.model = res.data
        self:_changed()
      else
        util.err(res.error or "set_model failed")
      end
    end
  )
end

function Session:get_models(cb)
  self.rpc:request({ type = "get_available_models" }, function(res)
    if res.success and res.data then
      cb(res.data.models or {})
    else
      util.err(res.error or "could not list models")
    end
  end)
end

function Session:cycle_model()
  self.rpc:request({ type = "cycle_model" }, function(res)
    if res.success and res.data then
      self.model = res.data.model
      self.thinking = res.data.thinkingLevel
      self:_changed()
    end
  end)
end

function Session:shutdown()
  self._closing = true
  if self.streaming then self:abort() end
  if self.rpc then self.rpc:shutdown() end
end

--- Rebuild transcript from the active branch when resuming a session file.
function Session:_rebuild()
  self.rpc:request({ type = "get_messages" }, function(res)
    if not (res.success and res.data) then
      self:_changed()
      return
    end
    self.transcript = {}
    self.tools_by_id = {}
    for _, m in ipairs(res.data.messages or {}) do
      if m.role == "user" then
        table.insert(self.transcript, { kind = "user", text = util.content_text(m.content) })
      elseif m.role == "assistant" then
        for _, b in ipairs(type(m.content) == "table" and m.content or {}) do
          if b.type == "text" and b.text and b.text ~= "" then
            table.insert(self.transcript, { kind = "assistant", text = b.text })
          elseif b.type == "thinking" and b.thinking then
            table.insert(self.transcript, { kind = "thinking", text = b.thinking })
          elseif b.type == "toolCall" then
            local t = { kind = "tool", name = b.name, args = b.arguments, output = "", done = true }
            self.tools_by_id[b.id] = t
            table.insert(self.transcript, t)
          end
        end
      elseif m.role == "toolResult" then
        local t = self.tools_by_id[m.toolCallId]
        if t then
          t.output = util.content_text(m.content)
          t.error = m.isError
        end
      elseif m.role == "bashExecution" then
        table.insert(self.transcript, {
          kind = "tool", name = "bash", args = { command = m.command },
          output = m.output or "", done = true, error = (m.exitCode or 0) ~= 0,
        })
      end
    end
    table.insert(self.transcript, { kind = "info", text = "session resumed" })
    self:_changed()
  end)
end

function Session:_on_event(ev)
  local t = ev.type
  if t == "agent_start" then
    self.streaming = true
    self._cur = nil
  elseif t == "agent_settled" then
    self.streaming = false
  elseif t == "agent_end" then
    if not ev.willRetry then self.streaming = false end
  elseif t == "message_update" then
    local e = ev.assistantMessageEvent or {}
    if e.type == "text_start" then
      self._cur = { kind = "assistant", text = "" }
      table.insert(self.transcript, self._cur)
    elseif e.type == "text_delta" and self._cur then
      self._cur.text = self._cur.text .. (e.delta or "")
    elseif e.type == "text_end" and self._cur then
      if e.content then self._cur.text = e.content end
      self._cur = nil
    elseif e.type == "thinking_start" then
      self._cur = { kind = "thinking", text = "" }
      table.insert(self.transcript, self._cur)
    elseif e.type == "thinking_delta" and self._cur then
      self._cur.text = self._cur.text .. (e.delta or "")
    elseif e.type == "thinking_end" then
      self._cur = nil
    end
  elseif t == "message_end" then
    self._cur = nil
  elseif t == "tool_execution_start" then
    local entry = { kind = "tool", name = ev.toolName, args = ev.args, output = "", done = false }
    self.tools_by_id[ev.toolCallId] = entry
    table.insert(self.transcript, entry)
  elseif t == "tool_execution_update" then
    local entry = self.tools_by_id[ev.toolCallId]
    if entry and ev.partialResult then
      entry.output = util.content_text(ev.partialResult.content)
    end
  elseif t == "tool_execution_end" then
    local entry = self.tools_by_id[ev.toolCallId]
    if entry then
      if ev.result then entry.output = util.content_text(ev.result.content) end
      entry.done = true
      entry.error = ev.isError
    end
  elseif t == "compaction_start" then
    table.insert(self.transcript, { kind = "info", text = "compacting context…" })
  elseif t == "compaction_end" then
    table.insert(self.transcript, { kind = "info", text = "context compacted" })
  elseif t == "auto_retry_start" then
    table.insert(self.transcript, {
      kind = "info",
      text = ("retrying (%d/%d) after transient error…"):format(ev.attempt or 0, ev.maxAttempts or 0),
    })
  elseif t == "extension_error" then
    table.insert(self.transcript, { kind = "error", text = "extension error: " .. (ev.error or "?") })
  elseif t == "extension_ui_request" then
    self:_ui_request(ev)
    return -- _ui_request notifies as needed
  else
    return -- ignore other events, no redraw needed
  end
  self:_changed()
end

--- Handle the extension UI sub-protocol (permission dialogs etc).
function Session:_ui_request(ev)
  local function respond(resp)
    resp.type = "extension_ui_response"
    resp.id = ev.id
    self.rpc:send(resp)
  end

  if ev.method == "select" then
    vim.ui.select(ev.options or {}, { prompt = ev.title or "pi" }, function(choice)
      if choice == nil then respond({ cancelled = true }) else respond({ value = choice }) end
    end)
  elseif ev.method == "confirm" then
    local prompt = ev.title or "pi"
    if ev.message then prompt = prompt .. " — " .. ev.message end
    vim.ui.select({ "Yes", "No" }, { prompt = prompt }, function(choice)
      if choice == nil then respond({ cancelled = true })
      else respond({ confirmed = choice == "Yes" }) end
    end)
  elseif ev.method == "input" or ev.method == "editor" then
    vim.ui.input({ prompt = (ev.title or "pi") .. ": ", default = ev.prefill }, function(value)
      if value == nil then respond({ cancelled = true }) else respond({ value = value }) end
    end)
  elseif ev.method == "notify" then
    local levels = { info = vim.log.levels.INFO, warning = vim.log.levels.WARN, error = vim.log.levels.ERROR }
    util.notify(ev.message or "", levels[ev.notifyType] or vim.log.levels.INFO)
  elseif ev.method == "setStatus" then
    self.status = ev.statusText
    self:_changed()
  end
  -- setWidget / setTitle / set_editor_text: ignored in nvim
end

return M
