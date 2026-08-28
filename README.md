# AwesomeVim

A fast, modern Neovim configuration with a built-in AI coding agent. It combines a lean plugin set, coherent keybindings, and a Cursor-style agent sidebar powered by [pi](https://github.com/earendil-works/pi), so you can chat with an agent that reads, edits, and runs code in your project while you keep editing as usual.

## Highlights

- **Agent sidebar (pi)**: a chat panel where AI agents do real work in your codebase
- **Blazingly fast**: minimal plugins, no bloat, quick startup
- **LSP ready**: completion, diagnostics, formatting, and go-to navigation out of the box
- **Treesitter**: modern syntax highlighting and parsing
- **Telescope**: fuzzy finding for files, text, buffers, and symbols
- **Coherent keybindings**: mnemonic namespaces designed to build muscle memory
- **One command installation**: a single script sets up everything

## The Agent Sidebar

The star of this config is `pi.nvim`, a hand-rolled integration of the pi coding agent, built into `lua/pi/`. It gives you an experience similar to Cursor, inside Neovim.

### What makes it agentic

The sidebar is not a chatbot that only answers questions. Each tab runs a full autonomous coding agent that can:

- **Read your code**: it explores the project with read, grep, find, and ls tools
- **Edit files directly**: it writes and patches files in your working tree
- **Run shell commands**: it executes builds, tests, and scripts, and reacts to their output
- **Work in multi-step loops**: it plans, acts, observes results, and continues until the task is done
- **Stream everything live**: you watch tool calls and reasoning appear in real time

Every tool call shows up as a compact status line in the transcript:

```
✓ read   src/main.go
✓ bash   go test ./...
✗ edit   src/api.go
│ failed: no match
▶ grep   TODO
```

### Non-blocking by design

The agent runs as a background process, completely decoupled from the UI:

- You can close the sidebar while the agent works, it keeps going
- You can edit, navigate, and search files while tasks run
- Multiple agents can run in parallel, one per tab
- Background tabs show a working indicator, so nothing gets lost

### Agent mode and Plan mode

Every tab runs in one of two modes:

- **Agent mode** (default): full tool access, the agent reads, edits, and executes
- **Plan mode**: read-only tools plus a planning prompt, the agent investigates the codebase and produces a step-by-step plan without touching any files

Toggle with `<Space>ap`. The conversation is preserved when switching modes.

### Tabs, sessions, and history

- Each tab is an independent pi session with its own process and context
- Create tabs with `<Space>an`, close with `<Space>ax`, cycle with `<Space>a]` and `<Space>a[`
- Closed tabs are saved to history, reopen any past session with `<Space>ah` and continue where you left off
- Sessions persist on disk in pi's own session format

### Model switching

- `<Space>am` opens a model picker listing every model you have configured in pi
- `:Pi cycle-model` cycles through available models
- Model choice is per tab, so different tabs can use different models

### Markdown and code rendering

The transcript renders as markdown with treesitter highlighting. Fenced code blocks get full syntax highlighting for their language, and render-markdown.nvim decorates headings, lists, and inline code.

### Agent commands

| Command | Action |
|---|---|
| `:Pi` | toggle the sidebar |
| `:Pi focus` | open and focus the chat input |
| `:Pi new [name]` | new tab (new session) |
| `:Pi close` | close current tab (saved to history) |
| `:Pi next` / `:Pi prev` | cycle tabs |
| `:Pi tab <n>` | jump to tab n |
| `:Pi history` | reopen a past session |
| `:Pi model` | model picker |
| `:Pi cycle-model` | cycle models |
| `:Pi mode` | toggle agent/plan mode |
| `:Pi abort` | abort the current run |
| `:Pi send <text>` | send a prompt programmatically |

### Agent configuration

Configure the sidebar in `init.lua`:

```lua
require("pi").setup({
    side = "right",           -- "left" or "right"
    width = 64,               -- sidebar width
    auto_focus = false,       -- focus input when opening
    default_mode = "agent",   -- "agent" or "plan"
    default_model = nil,      -- e.g. "anthropic/claude-sonnet-4:medium"
    render = {
        show_thinking = true,     -- show reasoning blocks
        show_tool_output = false, -- compact tool lines (errors always show)
        max_tool_lines = 12,      -- output tail length
    },
})
```

## Installation

### Requirements

- **Neovim** 0.10 or later
- **Git**
- **A C compiler** (gcc or clang, for treesitter parsers)
- **Node.js and npm** (for the pi coding agent)
- **An API key** for at least one LLM provider (Anthropic, OpenAI, Google, and others)

### One command install

```bash
curl -fsSL https://raw.githubusercontent.com/PythonHacker24/awesomevim/main/install.sh | bash
```

The script backs up any existing config, clones the repo, installs all plugins and treesitter parsers headlessly, and installs the pi CLI if npm is available.

After installing, authenticate pi once:

```bash
pi   # follow the login prompts, or set ANTHROPIC_API_KEY / OPENAI_API_KEY etc.
```

### Manual install

```bash
# 1. clone the config
git clone https://github.com/PythonHacker24/awesomevim.git ~/.config/nvim

# 2. install packer
git clone --depth 1 https://github.com/wbthomason/packer.nvim \
    ~/.local/share/nvim/site/pack/packer/start/packer.nvim

# 3. install plugins
nvim --headless -c "lua require('core.packer')" \
    -c "autocmd User PackerComplete quitall" -c "PackerSync"

# 4. install the pi coding agent
npm install -g @earendil-works/pi-coding-agent
```

## Keybindings

Leader is `Space`. The scheme is mnemonic: **leader, namespace letter, action letter**. The most used actions get instant chords.

### Instant habits

| Key | Action |
|---|---|
| `<Space><Space>` | find files |
| `Ctrl-\` | toggle floating terminal (works inside the terminal too) |
| `Ctrl-n` | toggle file tree |
| `<Space>aa` | toggle agent sidebar |

### `<Space>f` find (telescope)

| Key | Action |
|---|---|
| `<Space>ff` | files |
| `<Space>fg` | live grep |
| `<Space>fw` | grep word under cursor |
| `<Space>fb` | buffers |
| `<Space>fr` | recent files |
| `<Space>fs` | fuzzy search in buffer |
| `<Space>fd` | diagnostics |
| `<Space>fh` | help tags |
| `<Space>fc` | commands |

### `g` goto (LSP)

| Key | Action |
|---|---|
| `gd` | definition |
| `gr` | references |
| `gi` | implementation |
| `gy` | type definition |
| `K` | hover documentation |

### `<Space>s` symbols

| Key | Action |
|---|---|
| `<Space>ss` | document symbols |
| `<Space>sw` | workspace symbols |

### `<Space>t` terminal

| Key | Action |
|---|---|
| `<Space>tt` | floating terminal |
| `<Space>th` | horizontal terminal |
| `<Space>tv` | vertical terminal |
| `<Esc><Esc>` | (in terminal) back to normal mode |

### `<Space>a` agent (pi)

| Key | Action |
|---|---|
| `<Space>aa` | toggle sidebar |
| `<Space>ai` | focus chat input |
| `<Space>an` | new tab (session) |
| `<Space>ax` | close tab (saved to history) |
| `<Space>a]` / `<Space>a[` | next / previous tab |
| `<Space>ah` | reopen session from history |
| `<Space>am` | model picker |
| `<Space>ap` | toggle plan/agent mode |

Inside the sidebar:

| Key | Action |
|---|---|
| `<CR>` | send message (in input box) |
| `Ctrl-j` | newline in input |
| `Ctrl-c` | abort the current run |
| `q` | close sidebar |
| `i` | jump to input |
| `gt` / `gT` | next / previous tab |

### Misc

| Key | Action |
|---|---|
| `<Space>e` | focus file tree |
| `<Space>u` | undotree |
| `<Space>F` | LSP format |
| `<Space>/` | toggle comment (normal and visual) |
| `<Space>mp` | toggle markdown rendering |

### Smooth scrolling (neoscroll)

| Key | Action |
|---|---|
| `Ctrl-u` / `Ctrl-d` | half page up / down |
| `Ctrl-b` / `Ctrl-f` | full page up / down |
| `zt` / `zz` / `zb` | scroll cursor to top / center / bottom |

## Structure

```
init.lua              entry point
install.sh            one command installer
lua/
  core/
    options.lua       editor options
    keymaps.lua       all keybindings
    colors.lua        colorscheme with persistence
    packer.lua        plugin declarations
  plugins/            per-plugin configuration
    treesitter.lua, telescope via keymaps, lsp.lua, nvim-tree.lua,
    toggleterm.lua, lualine.lua, neoscroll.lua, hover.lua, startup.lua
  pi/                 the agent sidebar plugin
    init.lua          setup, :Pi command, keymaps
    rpc.lua           JSONL RPC client for pi subprocesses
    session.lua       one tab = one independent agent process
    manager.lua       tabs, history, mode and model actions
    ui.lua            sidebar windows, tabline, input
    render.lua        transcript to markdown rendering
    history.lua       persistent session index
  extras/
    latex.lua         :Renderlatex command
```

## Plugins

Managed with [packer.nvim](https://github.com/wbthomason/packer.nvim):

- [telescope.nvim](https://github.com/nvim-telescope/telescope.nvim) fuzzy finder
- [nvim-treesitter](https://github.com/nvim-treesitter/nvim-treesitter) syntax highlighting
- [mason.nvim](https://github.com/williamboman/mason.nvim) LSP server installer
- [nvim-cmp](https://github.com/hrsh7th/nvim-cmp) completion
- [nvim-tree](https://github.com/nvim-tree/nvim-tree.lua) file explorer
- [toggleterm.nvim](https://github.com/akinsho/toggleterm.nvim) terminal
- [lualine.nvim](https://github.com/nvim-lualine/lualine.nvim) statusline
- [render-markdown.nvim](https://github.com/MeanderingProgrammer/render-markdown.nvim) markdown decorations
- [Comment.nvim](https://github.com/numToStr/Comment.nvim) commenting
- [undotree](https://github.com/mbbill/undotree) undo history
- [neoscroll.nvim](https://github.com/karb94/neoscroll.nvim) smooth scrolling
- [go.nvim](https://github.com/ray-x/go.nvim) and [nvim-dap-go](https://github.com/leoluz/nvim-dap-go) Go development
- [catppuccin](https://github.com/catppuccin/nvim) and [gruvbox](https://github.com/morhetz/gruvbox) themes

### Adding plugins

1. Add a `use { ... }` entry in `lua/core/packer.lua`
2. Run `:lua require("core.packer")`
3. Run `:PackerSync`

## Bug Reports

Open an issue in the [issues tab](https://github.com/PythonHacker24/awesomevim/issues) with:

- steps to reproduce
- error messages (`:messages` in Neovim)
- your OS and Neovim version (`nvim --version`)

Pull requests are welcome.

## License

This project is licensed under the [MIT License](LICENSE).
