local M = {}

local defaults = {
  cmd = "pi", -- pi binary
  side = "right", -- "left" | "right"
  width = 64,
  input_height = 5,
  auto_focus = false, -- focus input when opening the sidebar
  default_mode = "agent", -- "agent" | "plan"
  default_model = nil, -- e.g. "anthropic/claude-sonnet-4:medium"
  session_dir = nil, -- override pi --session-dir
  cwd = nil, -- default: vim.fn.getcwd() at session spawn

  plan_tools = "read,grep,find,ls",
  plan_prompt = table.concat({
    "PLAN MODE ACTIVE.",
    "You are in planning mode: investigate the codebase using the available",
    "read-only tools, then produce a clear, numbered, step-by-step",
    "implementation plan. Do NOT modify any files and do NOT run commands",
    "that change state. End with open questions, if any.",
  }, " "),

  -- Extra context appended to every session's system prompt so the agent
  -- knows it runs inside Neovim and what the user's keybindings are.
  -- true = built-in context (lua/pi/context.lua), string = custom, false = off
  agent_context = true,

  render = {
    show_thinking = true,
    show_tool_output = false, -- compact: only tool name + status; errors always show
    max_tool_lines = 12,
  },

  history_file = vim.fn.stdpath("data") .. "/pi-nvim/history.json",

  -- Set to false to disable all default keymaps, or override individual ones.
  keymaps = {
    toggle = "<leader>aa",
    focus = "<leader>ai",
    new_tab = "<leader>an",
    close_tab = "<leader>ax",
    next_tab = "<leader>a]",
    prev_tab = "<leader>a[",
    history = "<leader>ah",
    model = "<leader>am",
    mode = "<leader>ap",
  },
}

local current = vim.deepcopy(defaults)

function M.setup(opts)
  current = vim.tbl_deep_extend("force", vim.deepcopy(defaults), opts or {})
  return current
end

function M.get()
  return current
end

return M
