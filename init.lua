local home = os.getenv("HOME")
local config = home .. '/.config/nvim'
package.path = package.path .. ';' .. config .. '/?.lua;' .. config .. '/?/init.lua'

vim.g.mapleader = " "
vim.g.maplocalleader = " "
vim.o.relativenumber = true
vim.o.number = true
vim.opt.undofile = true
vim.opt.undodir = os.getenv("HOME") .. "/.undodir"
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1
vim.opt.termguicolors = true

require "config.treesitter"
require "config.neoscroll"
require "custom.nvim-tree"

require "custom.set"
require "custom.latex"
require "custom.colors"
require "custom.golang"
require "custom.toggleterm"
require "custom.lualine"
require "custom.hover"

require("mason").setup()
require('dap-go').setup()

require "config.lsp"
require "config.telescope"
require "custom.remaps"

require("startup").setup({ theme = "dashboard" })
