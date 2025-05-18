-- telescope-keymaps.lua or inside your main confi 

local keymap = vim.keymap.set
local opts = { noremap = true, silent = true }

-- Telescope builtins
local builtin = require('telescope.builtin')

-- Common keymaps
keymap("n", "<leader>ff", builtin.find_files, opts)                -- find files
keymap("n", "<leader>fg", builtin.live_grep, opts)                 -- grep text
keymap("n", "<leader>fb", builtin.buffers, opts)                   -- open buffers
keymap("n", "<leader>fh", builtin.help_tags, opts)                 -- help tags
keymap("n", "<leader>fr", builtin.oldfiles, opts)                  -- recently opened files
keymap("n", "<leader>fc", builtin.commands, opts)                  -- command palette
keymap("n", "<leader>fs", builtin.current_buffer_fuzzy_find, opts) -- search in buffer

-- LSP-related Telescope pickers (if using LSP)
keymap("n", "<leader>gd", builtin.lsp_definitions, opts)
keymap("n", "<leader>gr", builtin.lsp_references, opts)
keymap("n", "<leader>gi", builtin.lsp_implementations, opts)
keymap("n", "<leader>gt", builtin.lsp_type_definitions, opts)
keymap("n", "<leader>ds", builtin.lsp_document_symbols, opts)
keymap("n", "<leader>ws", builtin.lsp_dynamic_workspace_symbols, opts)
