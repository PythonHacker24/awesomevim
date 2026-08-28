--- Default context appended to the system prompt of every sidebar session,
--- so the agent knows the environment it runs in and the user's keybindings.
--- Override or disable via require("pi").setup({ agent_context = ... }).
local M = {}

M.text = [[
## Environment: pi.nvim (Neovim agent sidebar)

You are running inside Neovim through pi.nvim, a chat sidebar in the user's
AwesomeVim config. The user keeps editing files while you work. Your tool
calls (read/edit/write/bash) operate on the project in the current working
directory. When you edit files the user sees changes immediately in their
open buffers.

Sidebar facts:
- Each chat tab is an independent pi session; the user can run several agents
  in parallel.
- Agent mode has full tools; Plan mode is read-only and produces plans.
- The user can abort you with Ctrl-C in the sidebar.

## User's keybindings (leader = Space)

If the user asks about keybindings or you write docs/config for them, this is
the active scheme (defined in lua/core/keymaps.lua, agent keys in lua/pi/):

- Instant: Space Space = find files, Ctrl-\ = toggle float terminal,
  Ctrl-n = file tree, Space aa = toggle this agent sidebar
- Find (Telescope): Space ff files, fg grep, fw word under cursor, fb buffers,
  fr recent, fs in-buffer search, fd diagnostics, fh help, fc commands
- Goto (LSP): gd definition, gr references, gi implementation,
  gy type definition, K hover
- Symbols: Space ss document, Space sw workspace
- Terminal (toggleterm): Space tt float, th horizontal, tv vertical,
  Esc Esc = terminal to normal mode
- Agent (pi.nvim): Space aa toggle, ai focus input, an new tab, ax close tab,
  a]/a[ cycle tabs, ah history, am model picker, ap toggle plan/agent mode;
  inside sidebar: Enter send, Ctrl-j newline, Ctrl-c abort, q close,
  gt/gT switch tabs. Ex command: :Pi (new/close/history/model/mode/send/...)
- Misc: Space e focus tree, Space u undotree, Space F format,
  Space / comment toggle, Space mp markdown render toggle
- Scrolling (neoscroll): Ctrl-u/d half page, Ctrl-b/f full page, zt/zz/zb

Config layout: init.lua entry; lua/core/ (options, keymaps, colors, packer);
lua/plugins/ (per-plugin configs); lua/pi/ (this sidebar); lua/extras/.
Plugins are managed with packer.nvim (lua/core/packer.lua, :PackerSync).
]]

return M
