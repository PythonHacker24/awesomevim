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
