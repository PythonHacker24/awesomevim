--- Sidebar UI: transcript window + input window, tabline + status via winbar.
--- The UI is only a view; sessions keep streaming with the sidebar closed.
local render = require("pi.render")

local api = vim.api
local M = {}

local ns = api.nvim_create_namespace("pi_nvim")

local st = {
  tbuf = nil, -- transcript buffer
  ibuf = nil, -- input buffer
  twin = nil,
  iwin = nil,
}

local function mgr()
  return require("pi.manager")
end

local function cfg()
  return require("pi.config").get()
end

local function valid_win(w)
  return w and api.nvim_win_is_valid(w)
end

local function valid_buf(b)
  return b and api.nvim_buf_is_valid(b)
end

function M.is_open()
  return valid_win(st.twin)
end

local function set_common_buf_opts(buf)
  vim.bo[buf].buftype = "nofile"
  vim.bo[buf].bufhidden = "hide"
  vim.bo[buf].swapfile = false
  vim.bo[buf].buflisted = false
end

-- Attach markdown treesitter highlighting + render-markdown.nvim (if present)
local function attach_markdown(buf)
  -- treesitter highlighting for markdown (+ injected code fences)
  pcall(vim.treesitter.start, buf, "markdown")
  local ok, rm = pcall(require, "render-markdown")
  if not ok then return end
  if not vim.g.pi_render_markdown_setup then
    -- user config keeps render-markdown disabled globally; we enable per-buffer
    pcall(rm.setup, { enabled = false })
    vim.g.pi_render_markdown_setup = true
  end
  api.nvim_buf_call(buf, function()
    pcall(rm.buf_enable)
  end)
  st.rm = true
end

local function ensure_bufs()
  if not valid_buf(st.tbuf) then
    st.tbuf = api.nvim_create_buf(false, true)
    set_common_buf_opts(st.tbuf)
    vim.bo[st.tbuf].modifiable = false
    vim.bo[st.tbuf].filetype = "markdown"
    attach_markdown(st.tbuf)
    local opts = { buffer = st.tbuf, silent = true }
    vim.keymap.set("n", "q", function() M.close() end, opts)
    vim.keymap.set("n", "i", function() M.focus_input() end, opts)
    vim.keymap.set("n", "<CR>", function() M.focus_input() end, opts)
    vim.keymap.set("n", "gt", function() mgr().cycle(1) end, opts)
    vim.keymap.set("n", "gT", function() mgr().cycle(-1) end, opts)
    vim.keymap.set("n", "<C-c>", function() mgr().abort_active() end, opts)
  end
  if not valid_buf(st.ibuf) then
    st.ibuf = api.nvim_create_buf(false, true)
    set_common_buf_opts(st.ibuf)
    vim.bo[st.ibuf].filetype = "pi-input"
    local opts = { buffer = st.ibuf, silent = true }
    vim.keymap.set({ "n", "i" }, "<CR>", function() M.submit() end, opts)
    vim.keymap.set("i", "<S-CR>", "<CR>", { buffer = st.ibuf }) -- literal newline
    vim.keymap.set("i", "<C-j>", "<CR>", { buffer = st.ibuf }) -- literal newline
    vim.keymap.set({ "n", "i" }, "<C-c>", function() mgr().abort_active() end, opts)
    vim.keymap.set("n", "q", function() M.close() end, opts)
  end
end

local function setup_win(win, is_input)
  vim.wo[win].number = false
  vim.wo[win].relativenumber = false
  vim.wo[win].signcolumn = "no"
  vim.wo[win].foldcolumn = "0"
  vim.wo[win].wrap = true
  vim.wo[win].linebreak = true
  vim.wo[win].winfixwidth = true
  vim.wo[win].list = false
  vim.wo[win].spell = false
  if is_input then
    vim.wo[win].winfixheight = true
  else
    vim.wo[win].conceallevel = 3
    vim.wo[win].concealcursor = "nvc"
  end
end

function M.open()
  if M.is_open() then
    M.render()
    return
  end
  ensure_bufs()
  mgr().ensure_session()

  local prev_win = api.nvim_get_current_win()
  local c = cfg()
  local dir = c.side == "left" and "topleft" or "botright"

  vim.cmd(dir .. " vertical " .. c.width .. "split")
  st.twin = api.nvim_get_current_win()
  api.nvim_win_set_buf(st.twin, st.tbuf)
  setup_win(st.twin, false)

  vim.cmd("belowright " .. c.input_height .. "split")
  st.iwin = api.nvim_get_current_win()
  api.nvim_win_set_buf(st.iwin, st.ibuf)
  setup_win(st.iwin, true)

  M.render()

  if c.auto_focus then
    api.nvim_set_current_win(st.iwin)
    vim.cmd("startinsert")
  else
    -- do not disturb whatever the user was doing
    if api.nvim_win_is_valid(prev_win) then
      api.nvim_set_current_win(prev_win)
    end
  end
end

function M.close()
  for _, w in ipairs({ st.iwin, st.twin }) do
    if valid_win(w) then
      pcall(api.nvim_win_close, w, true)
    end
  end
  st.twin, st.iwin = nil, nil
end

function M.toggle()
  if M.is_open() then M.close() else M.open() end
end

function M.focus_input()
  if not M.is_open() then M.open() end
  if valid_win(st.iwin) then
    api.nvim_set_current_win(st.iwin)
    vim.cmd("startinsert!")
  end
end

function M.submit()
  if not valid_buf(st.ibuf) then return end
  local text = table.concat(api.nvim_buf_get_lines(st.ibuf, 0, -1, false), "\n")
  text = vim.trim(text)
  if text == "" then return end
  api.nvim_buf_set_lines(st.ibuf, 0, -1, false, {})
  mgr().prompt_active(text)
  M.schedule_render()
end

-- ------------------------------------------------------------------ render

local function esc(s)
  return (s:gsub("%%", "%%%%"))
end

local function tabline_str()
  local m = mgr()
  local parts = {}
  for i, s in ipairs(m.sessions) do
    local hl = (i == m.active) and "%#PiTabActive#" or "%#PiTabInactive#"
    local flag = ""
    if s.dead then
      flag = " ✗"
    elseif s.streaming then
      flag = " ●"
    elseif s.unread then
      flag = " *"
    end
    parts[#parts + 1] = string.format("%s %d:%s%s ", hl, i, esc(s.name), flag)
  end
  parts[#parts + 1] = "%#PiTabInactive# + "
  return table.concat(parts)
end

local function status_str()
  local s = mgr().active_session()
  if not s then return "%#PiStatus# pi " end
  local mode = s.mode == "plan" and "PLAN" or "AGENT"
  local model = s.model and s.model.id or "…"
  local extra = ""
  if s.streaming then extra = "  working…" end
  if s.status then extra = extra .. "  " .. esc(s.status) end
  return string.format("%%#PiStatus# %s  %s%s ", mode, esc(model), extra)
end

function M.render()
  if not M.is_open() then return end
  local m = mgr()
  local s = m.active_session()
  if s then s.unread = false end

  local lines, hls = render.lines(s, cfg())

  vim.bo[st.tbuf].modifiable = true
  api.nvim_buf_set_lines(st.tbuf, 0, -1, false, lines)
  vim.bo[st.tbuf].modifiable = false

  api.nvim_buf_clear_namespace(st.tbuf, ns, 0, -1)
  for _, h in ipairs(hls) do
    pcall(api.nvim_buf_set_extmark, st.tbuf, ns, h.line, 0, {
      end_row = h.line + 1,
      end_col = 0,
      hl_group = h.hl,
      hl_eol = true,
    })
  end

  -- force render-markdown to refresh decorations after programmatic changes
  if st.rm then
    pcall(function()
      require("render-markdown.api").render({ buf = st.tbuf, win = st.twin, event = "TextChanged" })
    end)
  end

  -- winbars: tabs on transcript, status on input
  if valid_win(st.twin) then
    vim.wo[st.twin].winbar = tabline_str()
    -- auto-scroll to bottom unless the user is browsing the transcript
    if api.nvim_get_current_win() ~= st.twin then
      pcall(api.nvim_win_set_cursor, st.twin, { #lines, 0 })
    end
  end
  if valid_win(st.iwin) then
    vim.wo[st.iwin].winbar = status_str()
  end
end

local pending = false
function M.schedule_render()
  if pending then return end
  pending = true
  vim.defer_fn(function()
    pending = false
    M.render()
  end, 60)
end

return M
