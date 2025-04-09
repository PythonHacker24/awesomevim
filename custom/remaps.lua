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

vim.keymap.set('n', '<leader>m', vim.cmd.UndotreeToggle)

vim.keymap.set("n", "K", require("hover").hover, { desc = "hover.nvim" })
vim.keymap.set("n", "gK", require("hover").hover_select, { desc = "hover.nvim (select)" })
vim.keymap.set("n", "<C-p>", function()
    require("hover").hover_switch("previous")
end, { desc = "hover.nvim (previous source)" })
vim.keymap.set("n", "<C-n>", function()
    require("hover").hover_switch("next")
end, { desc = "hover.nvim (next source)" })
