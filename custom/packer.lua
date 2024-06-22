vim.cmd [[packadd packer.nvim]]

return require('packer').startup(function(use)
	-- Packer can manage itself
	use 'wbthomason/packer.nvim'

	-- Telescope 
	use {
	  'nvim-telescope/telescope.nvim', tag = '0.1.8',
	-- or                            , branch = '0.1.x',
	  requires = { {'nvim-lua/plenary.nvim'} }
	}

	-- Catppuccin Colorscheme
	use { "catppuccin/nvim", as = "catppuccin" }
	
	-- Smooth Scroll
	use 'karb94/neoscroll.nvim'
	
	-- Treesitter 
	use ('nvim-treesitter/nvim-treesitter', {run = ':TSUpdate'})
	
	-- Treesitter Playground 
	use 'nvim-treesitter/playground'

	-- LSP config 
	use {
		'VonHeikemen/lsp-zero.nvim',
		branch = 'v3.x',
		requires = {
			--- Uncomment the two plugins below if you want to manage the language servers from neovim
			-- {'williamboman/mason.nvim'},
			-- {'williamboman/mason-lspconfig.nvim'},

			{'neovim/nvim-lspconfig'},
			{'hrsh7th/nvim-cmp'},
			{'hrsh7th/cmp-nvim-lsp'},
			{'L3MON4D3/LuaSnip'},
		}
	}

	-- Mason Config 
	use {
    		"williamboman/mason.nvim",
    		"williamboman/mason-lspconfig.nvim",
    		"neovim/nvim-lspconfig",
	}

	-- Nvim Tree
	use {
		'nvim-tree/nvim-tree.lua',
		requires = {
		'nvim-tree/nvim-web-devicons', -- optional
	},
	
	-- Terminal for NeoVim
	use {"akinsho/toggleterm.nvim", tag = '*', config = function()
	  require("toggleterm").setup()
	end},

    -- Harpoon  
    use "nvim-lua/plenary.nvim", -- don't forget to add this one if you don't have it yet!
    use {
        "ThePrimeagen/harpoon",
        branch = "harpoon2",
        requires = { {"nvim-lua/plenary.nvim"} }
    },
    use {
      'nvim-lualine/lualine.nvim',
      requires = { 'nvim-tree/nvim-web-devicons', opt = true }
    },
}
end)
