local null_ls = require("null-ls")

-- Set up null-ls for formatters
null_ls.setup({
  sources = {
    null_ls.builtins.formatting.prettier,  -- JavaScript, TypeScript, CSS, HTML
    null_ls.builtins.formatting.black,     -- Python
    null_ls.builtins.formatting.stylua,    -- Lua
    null_ls.builtins.formatting.clang_format, -- C, C++
  },
})

-- Keybinding to manually format the buffer
vim.api.nvim_set_keymap('n', '<leader>m', '<cmd>lua vim.lsp.buf.format({ async = true })<CR>', { noremap = true, silent = true })
