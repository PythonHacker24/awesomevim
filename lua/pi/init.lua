--- pi.nvim — Cursor-style agent chat sidebar backed by `pi --mode rpc`.
local M = {}

local function ui() return require("pi.ui") end
local function mgr() return require("pi.manager") end

local function define_highlights()
  local hl = vim.api.nvim_set_hl
  hl(0, "PiHeader", { link = "Title", default = true })
  hl(0, "PiUserHeader", { link = "Function", default = true })
  hl(0, "PiUser", { link = "String", default = true })
  hl(0, "PiThinking", { link = "Comment", default = true })
  hl(0, "PiTool", { link = "Identifier", default = true })
  hl(0, "PiToolRunning", { link = "WarningMsg", default = true })
  hl(0, "PiToolOutput", { link = "Comment", default = true })
  hl(0, "PiInfo", { link = "NonText", default = true })
  hl(0, "PiError", { link = "ErrorMsg", default = true })
  hl(0, "PiTabActive", { link = "TabLineSel", default = true })
  hl(0, "PiTabInactive", { link = "TabLine", default = true })
  hl(0, "PiStatus", { link = "StatusLine", default = true })
end

local subcommands = {
  toggle = function() ui().toggle() end,
  open = function() ui().open() end,
  ["close-sidebar"] = function() ui().close() end,
  focus = function() ui().focus_input() end,
  new = function(args)
    mgr().new_session({ name = args ~= "" and args or nil })
    ui().open()
  end,
  close = function() mgr().close_active() end,
  next = function() mgr().cycle(1) end,
  prev = function() mgr().cycle(-1) end,
  tab = function(args)
    local n = tonumber(args)
    if n then mgr().switch_to(n) end
  end,
  history = function() mgr().history_picker() end,
  model = function() mgr().model_picker() end,
  ["cycle-model"] = function()
    local s = mgr().active_session()
    if s then s:cycle_model() end
  end,
  mode = function() mgr().toggle_mode() end,
  abort = function() mgr().abort_active() end,
  send = function(args)
    if args ~= "" then
      mgr().prompt_active(args)
      ui().open()
    end
  end,
}

local function setup_commands()
  vim.api.nvim_create_user_command("Pi", function(opts)
    local sub, rest = opts.fargs[1], table.concat(vim.list_slice(opts.fargs, 2), " ")
    if not sub then
      ui().toggle()
      return
    end
    local fn = subcommands[sub]
    if fn then
      fn(rest)
    else
      require("pi.util").err("unknown subcommand: " .. sub)
    end
  end, {
    nargs = "*",
    complete = function(arg_lead)
      local keys = vim.tbl_keys(subcommands)
      table.sort(keys)
      return vim.tbl_filter(function(k)
        return vim.startswith(k, arg_lead)
      end, keys)
    end,
    desc = "pi agent chat sidebar",
  })
end

local function setup_keymaps(keymaps)
  if keymaps == false then return end
  local map = function(lhs, rhs, desc)
    if lhs then vim.keymap.set("n", lhs, rhs, { silent = true, desc = "pi: " .. desc }) end
  end
  map(keymaps.toggle, function() ui().toggle() end, "toggle sidebar")
  map(keymaps.focus, function() ui().focus_input() end, "focus input")
  map(keymaps.new_tab, function() subcommands.new("") end, "new tab")
  map(keymaps.close_tab, function() mgr().close_active() end, "close tab")
  map(keymaps.next_tab, function() mgr().cycle(1) end, "next tab")
  map(keymaps.prev_tab, function() mgr().cycle(-1) end, "prev tab")
  map(keymaps.history, function() mgr().history_picker() end, "session history")
  map(keymaps.model, function() mgr().model_picker() end, "model picker")
  map(keymaps.mode, function() mgr().toggle_mode() end, "toggle plan/agent mode")
end

function M.setup(opts)
  local cfg = require("pi.config").setup(opts)
  define_highlights()
  vim.api.nvim_create_autocmd("ColorScheme", { callback = define_highlights })
  setup_commands()
  setup_keymaps(cfg.keymaps)
  vim.api.nvim_create_autocmd("VimLeavePre", {
    callback = function()
      require("pi.manager").shutdown_all()
    end,
  })
end

-- convenience API
M.toggle = function() ui().toggle() end
M.open = function() ui().open() end
M.send = function(text) mgr().prompt_active(text) end

return M
