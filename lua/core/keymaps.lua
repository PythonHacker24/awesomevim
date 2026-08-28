-- ============================================================================
-- Keymaps (see README.md for the full cheatsheet)
--
--   Instant habits:
--     <leader><leader>  find files
--     <C-\>             toggle float terminal (works inside terminal too)
--     <C-n>             toggle file tree
--     <leader>aa        toggle pi agent sidebar (set in lua/pi)
--
--   Namespaces (mnemonic first letter):
--     <leader>f_  find (telescope)      <leader>a_  agent (pi)
--     <leader>t_  terminal              <leader>s_  symbols
--     g_          goto (LSP)            <leader>m_  markdown
-- ============================================================================

local map = vim.keymap.set
local opts = function(desc)
    return { noremap = true, silent = true, desc = desc }
end

-- ------------------------------------------------------------------ file tree
map("n", "<C-n>", function() require("nvim-tree.api").tree.toggle() end, opts("tree: toggle"))
map("n", "<leader>e", function() require("nvim-tree.api").tree.focus() end, opts("tree: focus"))

-- ------------------------------------------------------------------- terminal
local Terminal = require("toggleterm.terminal").Terminal
local float_term = Terminal:new({ direction = "float", id = 1 })
local horiz_term = Terminal:new({ direction = "horizontal", id = 2 })
local vert_term  = Terminal:new({ direction = "vertical", id = 3 })

-- primary: one chord, from anywhere (normal or inside the terminal)
map({ "n", "t" }, [[<C-\>]], function() float_term:toggle() end, opts("terminal: toggle float"))

map("n", "<leader>tt", function() float_term:toggle() end, opts("terminal: float"))
map("n", "<leader>th", function() horiz_term:toggle() end, opts("terminal: horizontal"))
map("n", "<leader>tv", function() vert_term:toggle() end, opts("terminal: vertical"))

-- escape terminal-mode with a double tap
map("t", "<Esc><Esc>", [[<C-\><C-n>]], opts("terminal: to normal mode"))

-- ----------------------------------------------------------- find (telescope)
local builtin = require("telescope.builtin")

-- instant habit: double-tap leader for files
map("n", "<leader><leader>", builtin.find_files, opts("find: files"))

map("n", "<leader>ff", builtin.find_files, opts("find: files"))
map("n", "<leader>fg", builtin.live_grep, opts("find: grep"))
map("n", "<leader>fw", builtin.grep_string, opts("find: word under cursor"))
map("n", "<leader>fb", builtin.buffers, opts("find: buffers"))
map("n", "<leader>fr", builtin.oldfiles, opts("find: recent files"))
map("n", "<leader>fh", builtin.help_tags, opts("find: help"))
map("n", "<leader>fc", builtin.commands, opts("find: commands"))
map("n", "<leader>fs", builtin.current_buffer_fuzzy_find, opts("find: in buffer"))
map("n", "<leader>fd", builtin.diagnostics, opts("find: diagnostics"))

-- ------------------------------------------------------------------ goto (LSP)
map("n", "gd", builtin.lsp_definitions, opts("goto: definition"))
map("n", "gr", builtin.lsp_references, opts("goto: references"))
map("n", "gi", builtin.lsp_implementations, opts("goto: implementation"))
map("n", "gy", builtin.lsp_type_definitions, opts("goto: type definition"))

-- --------------------------------------------------------------------- symbols
map("n", "<leader>ss", builtin.lsp_document_symbols, opts("symbols: document"))
map("n", "<leader>sw", builtin.lsp_dynamic_workspace_symbols, opts("symbols: workspace"))

-- -------------------------------------------------------------------- undotree
map("n", "<leader>u", vim.cmd.UndotreeToggle, opts("undotree: toggle"))

-- ------------------------------------------------------------------------ code
map("n", "<leader>F", function() vim.lsp.buf.format({ async = true }) end, opts("lsp: format"))

map("n", "<leader>/", function() require("Comment.api").toggle.linewise.current() end, opts("comment: toggle line"))
map("v", "<leader>/", function() require("Comment.api").toggle.linewise(vim.fn.visualmode()) end, opts("comment: toggle selection"))

-- -------------------------------------------------------------------- markdown
map("n", "<leader>mp", function()
    local ok, rm = pcall(require, "render-markdown")
    if not ok then return end
    if not vim.g.pi_render_markdown_setup then
        pcall(rm.setup, { enabled = false })
        vim.g.pi_render_markdown_setup = true
    end
    rm.buf_toggle()
end, opts("markdown: toggle render"))
