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
vim.keymap.set("n", "<leader>tt", vim.cmd.TransparentToggle)

local builtin = require('telescope.builtin')

vim.keymap.set('n', '<C-p>', builtin.git_files, {})
