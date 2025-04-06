vim.g.mapleader = " "

-- Nvim Tree Toggling
local treeState = 0
vim.keymap.set("n", "<C-n>", function()
    if treeState == 0 then
        vim.cmd.NvimTreeOpen()
        treeState = 1
    else
        vim.cmd.NvimTreeClose()
        treeState = 0
    end
end)

vim.keymap.set("n", "<leader>h", vim.cmd.ToggleTerm)

local builtin = require('telescope.builtin')

vim.keymap.set('n', '<C-p>', builtin.git_files, {})

vim.keymap.set('n', '<leader>ps', function()
    builtin.grep_string({ search = vim.fn.input("Grep > ") });
end)

vim.keymap.set('n', '<leader>m', vim.cmd.UndotreeToggle)
