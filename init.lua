local home = os.getenv("HOME")
local config = home .. '/.config/nvim'
package.path = package.path .. ';' .. config .. '/?.lua;' .. config .. '/?/init.lua'

-- Enable relative line numbers
vim.o.relativenumber = true

-- Enable absolute line numbers
vim.o.number = true

-- Required lua modules 
require "custom.remaps"
require "custom.set"
require "config.telescope"
require "config.treesitter"
require "config.lsp"

-- Undo Configuration
vim.opt.undofile = true
vim.opt.undodir = os.getenv("HOME") .. "/.undodir"

-- Default Theme - Catppuccin Mocha 
vim.cmd.colorscheme "catppuccin-mocha"

-- Configure Smooth Scrolling 
require('neoscroll').setup({
  mappings = {                 -- Keys to be mapped to their corresponding default scrolling animation
    '<C-u>', '<C-d>',
    '<C-b>', '<C-f>',
    '<C-y>', '<C-e>',
    'zt', 'zz', 'zb',
  },
  hide_cursor = true,          -- Hide cursor while scrolling
  stop_eof = true,             -- Stop at <EOF> when scrolling downwards
  respect_scrolloff = false,   -- Stop scrolling when the cursor reaches the scrolloff margin of the file
  cursor_scrolls_alone = true, -- The cursor will keep on scrolling even if the window cannot scroll further
  easing = 'linear',           -- Default easing function
  pre_hook = nil,              -- Function to run before the scrolling animation starts
  post_hook = nil,             -- Function to run after the scrolling animation ends
  performance_mode = false,    -- Disable "Performance Mode" on all buffers.
})

-- disable netrw at the very start of your init.lua
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- optionally enable 24-bit colour
vim.opt.termguicolors = true

-- empty setup using defaults
require("nvim-tree").setup()

-- OR setup with some options
require("nvim-tree").setup({
  sort = {
    sorter = "case_sensitive",
  },
  view = {
    width = 30,
  },
  renderer = {
    group_empty = true,
  },
  filters = {
    dotfiles = true,
  },
})

-- NeoVim Terminal Configuration
require("toggleterm").setup{
	function(term)
    	if term.direction == "horizontal" then
      		return 15
    	elseif term.direction == "vertical" then
      		return vim.o.columns * 0.4
    	end
	end,
	direction = 'float',
}

-- Status Line 
require('lualine').setup {
  options = {
    icons_enabled = true,
    theme = 'auto',
    component_separators = { left = '', right = ''},
    section_separators = { left = '', right = ''},
    disabled_filetypes = {
      statusline = {},
      winbar = {},
    },
    ignore_focus = {},
    always_divide_middle = true,
    globalstatus = false,
    refresh = {
      statusline = 1000,
      tabline = 1000,
      winbar = 1000,
    }
  },
  sections = {
    lualine_a = {'mode'},
    lualine_b = {'branch', 'diff', 'diagnostics'},
    lualine_c = {'filename'},
    lualine_x = {'encoding', 'fileformat', 'filetype'},
    lualine_y = {'progress'},
    lualine_z = {'location'}
  },
  inactive_sections = {
    lualine_a = {'mode'},
    lualine_b = {'branch', 'diff', 'diagnostics'},
    lualine_c = {'filename'},
    lualine_x = {'encoding', 'fileformat', 'filetypes'},
    lualine_y = {'progress'},
    lualine_z = {'location'}
  },
  tabline = {},
  winbar = {},
  inactive_winbar = {},
  extensions = {}
}

-- Startup 
require("startup").setup({theme = "dashboard"})
