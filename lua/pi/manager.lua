--- SessionManager: tabs (sessions), switching, history, mode/model actions.
local Session = require("pi.session")
local history = require("pi.history")
local util = require("pi.util")

local M = {
  sessions = {},
  active = 0,
}

local function ui()
  return require("pi.ui")
end

local function cfg()
  return require("pi.config").get()
end

function M.active_session()
  return M.sessions[M.active]
end

local function on_update(s)
  if s ~= M.active_session() then
    s.unread = true
  end
  ui().schedule_render()
end

--- opts: { name?, mode?, session_path?, cwd? }
function M.new_session(opts)
  opts = opts or {}
  local s = Session.new({
    name = opts.name,
    mode = opts.mode or cfg().default_mode,
    session_path = opts.session_path,
    cwd = opts.cwd,
    cfg = cfg(),
    on_update = on_update,
  })
  table.insert(M.sessions, s)
  M.active = #M.sessions
  ui().schedule_render()
  return s
end

function M.ensure_session()
  if #M.sessions == 0 then
    return M.new_session()
  end
  return M.active_session()
end

function M.switch_to(idx)
  if M.sessions[idx] then
    M.active = idx
    M.sessions[idx].unread = false
    ui().schedule_render()
  end
end

function M.cycle(delta)
  local n = #M.sessions
  if n == 0 then return end
  M.switch_to(((M.active - 1 + delta) % n) + 1)
end

local function record_history(s)
  if not s.session_file then return end
  history.add({
    name = s.name,
    session_file = s.session_file,
    mode = s.mode,
    cwd = s.cwd,
    model = s.model and (s.model.provider .. "/" .. s.model.id) or nil,
    last_used = os.time(),
  })
end

function M.close_active()
  local s = M.active_session()
  if not s then return end
  record_history(s)
  s:shutdown()
  table.remove(M.sessions, M.active)
  if M.active > #M.sessions then M.active = #M.sessions end
  if M.sessions[M.active] then M.sessions[M.active].unread = false end
  ui().schedule_render()
end

function M.prompt_active(text)
  text = util.trim(text or "")
  if text == "" then return end
  M.ensure_session():prompt(text)
end

function M.abort_active()
  local s = M.active_session()
  if s then s:abort() end
end

--- Toggle agent/plan on the active tab. Tools are fixed per process, so we
--- restart the subprocess against the same session file.
function M.toggle_mode()
  local s = M.active_session()
  if not s then
    util.err("no active session")
    return
  end
  if not s.session_file then
    util.err("session not persisted yet; try again in a moment")
    return
  end
  local new_mode = s.mode == "plan" and "agent" or "plan"
  local idx = M.active
  record_history(s)
  s:shutdown()
  local replacement = Session.new({
    name = s.name,
    mode = new_mode,
    session_path = s.session_file,
    cwd = s.cwd,
    cfg = cfg(),
    on_update = on_update,
  })
  M.sessions[idx] = replacement
  util.notify("switched to " .. new_mode:upper() .. " mode")
  ui().schedule_render()
end

function M.model_picker()
  local s = M.ensure_session()
  s:get_models(function(models)
    if #models == 0 then
      util.err("no models available (check pi auth)")
      return
    end
    vim.ui.select(models, {
      prompt = "pi model",
      format_item = function(m)
        return string.format("%s/%s  (%s)", m.provider, m.id, m.name or "")
      end,
    }, function(choice)
      if choice then s:set_model(choice.provider, choice.id) end
    end)
  end)
end

function M.history_picker()
  local entries = history.list()
  if #entries == 0 then
    util.notify("no session history yet")
    return
  end
  -- hide sessions that are currently open
  local open = {}
  for _, s in ipairs(M.sessions) do
    if s.session_file then open[s.session_file] = true end
  end
  entries = vim.tbl_filter(function(e) return not open[e.session_file] end, entries)
  if #entries == 0 then
    util.notify("all recorded sessions are already open")
    return
  end
  vim.ui.select(entries, {
    prompt = "pi session history",
    format_item = function(e)
      local when = e.last_used and os.date("%Y-%m-%d %H:%M", e.last_used) or "?"
      return string.format("%s  [%s]  %s", e.name or "?", e.mode or "agent", when)
    end,
  }, function(choice)
    if not choice then return end
    M.new_session({
      name = choice.name,
      mode = choice.mode,
      session_path = choice.session_file,
      cwd = choice.cwd,
    })
    require("pi.ui").open()
  end)
end

--- Shut everything down (VimLeavePre).
function M.shutdown_all()
  for _, s in ipairs(M.sessions) do
    record_history(s)
    s:shutdown()
  end
  M.sessions = {}
  M.active = 0
end

return M
