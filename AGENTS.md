# AwesomeVim (Neovim config)

This repo is a Neovim configuration with a built-in pi agent sidebar (pi.nvim).

## Layout

- `init.lua` entry point, ordered requires
- `lua/core/` editor fundamentals
  - `options.lua` editor options
  - `keymaps.lua` ALL keybindings live here (single source of truth)
  - `colors.lua` colorscheme persistence
  - `packer.lua` plugin declarations (packer.nvim, self-bootstrapping)
- `lua/plugins/` one config file per plugin (treesitter, lsp, nvim-tree, toggleterm, lualine, neoscroll, hover, startup)
- `lua/pi/` the agent sidebar plugin
  - `rpc.lua` JSONL client for `pi --mode rpc` subprocesses
  - `session.lua` one tab = one agent process; event handling
  - `manager.lua` tabs, history, mode/model actions
  - `ui.lua` sidebar windows, tabline, input
  - `render.lua` transcript rendering (markdown + compact tool lines)
  - `context.lua` system-prompt context injected into sidebar sessions
  - `history.lua` persistent session index
- `lua/extras/` small utilities (`latex.lua`)
- `install.sh` one command installer
- `plugin/packer_compiled.lua` generated, gitignored

## Conventions

- Keybinding scheme is mnemonic: leader (Space) + namespace letter + action.
  Namespaces: f find, g goto (no leader), s symbols, t terminal, a agent.
  Instant chords: Space Space (files), Ctrl-\ (terminal), Ctrl-n (tree),
  Space aa (agent sidebar). Full reference is in README.md.
- New keybindings go in `lua/core/keymaps.lua` (or pi setup for agent keys),
  and must be documented in README.md and `lua/pi/context.lua`.
- New plugins: add `use { ... }` in `lua/core/packer.lua`, create a config
  file in `lua/plugins/`, require it from `init.lua`, run :PackerSync.
- Verify changes headlessly:
  `nvim --headless -c "lua print('ok')" -c "qa!"` must produce no errors.
- Do not commit `plan.md`, `.pi/`, or `plugin/packer_compiled.lua` (gitignored).
