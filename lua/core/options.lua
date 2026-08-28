-- ============================================================================
-- Editor options
-- ============================================================================

local opt = vim.opt

-- line numbers
opt.nu = true
opt.relativenumber = true

-- clipboard shared with the system
opt.clipboard = "unnamedplus"

-- indentation
opt.tabstop = 4
opt.softtabstop = 4
opt.shiftwidth = 4
opt.expandtab = true
opt.smartindent = true

-- ui
opt.termguicolors = true
opt.scrolloff = 8
opt.signcolumn = "yes"
opt.isfname:append("@-@")

-- persistent undo
opt.undofile = true
opt.undodir = os.getenv("HOME") .. "/.undodir"

-- faster CursorHold and diagnostics
opt.updatetime = 250

-- disable netrw (nvim-tree replaces it)
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1
