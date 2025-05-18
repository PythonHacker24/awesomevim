vim.g.mapleader = " "
vim.g.maplocalleader = " "

vim.keymap.set("n", "<leader>", "<Nop>", { noremap = true, silent = true })

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

-- For terminal toggling
vim.keymap.set("n", "<leader>h", vim.cmd.ToggleTerm)

-- For undotree toggling
vim.keymap.set('n', '<leader>m', vim.cmd.UndotreeToggle)

-- For formating code
vim.keymap.set("n", "<leader>F", function()
    vim.lsp.buf.format { async = true }
end, { noremap = true, silent = true })
