-- ============================================================================
-- AwesomeVim entry point
--
--   lua/core/     options, keymaps, colorscheme, plugin declarations
--   lua/plugins/  per-plugin configuration
--   lua/pi/       pi agent chat sidebar (agentic coding assistant)
--   lua/extras/   small utilities (latex rendering, ...)
-- ============================================================================

-- leader must be set before any keymaps or plugins load
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- core
require("core.options")
require("core.colors")

-- plugins
require("plugins.treesitter")
require("plugins.neoscroll")
require("plugins.nvim-tree")
require("plugins.toggleterm")
require("plugins.lualine")
require("plugins.hover")
require("plugins.lsp")
require("plugins.startup")

-- keymaps (after plugins, since some maps reference plugin modules)
require("core.keymaps")

-- extras
require("extras.latex")

-- pi agent chat sidebar
require("pi").setup({})
