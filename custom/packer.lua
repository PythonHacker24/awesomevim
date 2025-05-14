vim.cmd [[packadd packer.nvim]]

return require('packer').startup(function(use)
	-- Packer can manage itself
	use 'wbthomason/packer.nvim'
    
    use 'arcticicestudio/nord-vim'

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
	-- use {
-- 		'VonHeikemen/lsp-zero.nvim',
-- 		branch = 'v3.x',
-- 		requires = {
-- 			--- Uncomment the two plugins below if you want to manage the language servers from neovim
-- 			-- {'williamboman/mason.nvim'},
-- 			-- {'williamboman/mason-lspconfig.nvim'},
-- 
-- 			{'neovim/nvim-lspconfig'},
-- 			{'hrsh7th/nvim-cmp'},
-- 			{'hrsh7th/cmp-nvim-lsp'},
-- 			{'L3MON4D3/LuaSnip'},
-- 		}
-- 	}

    use({
        "nvimtools/none-ls.nvim",
        config = function()
            require("null-ls").setup()
        end,
        requires = { "nvim-lua/plenary.nvim" },
    });

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

    use "nvim-lua/plenary.nvim",

    use {
      'nvim-lualine/lualine.nvim',
      requires = { 'nvim-tree/nvim-web-devicons', opt = true }
    },

    use {
      "startup-nvim/startup.nvim",
      requires = {"nvim-telescope/telescope.nvim", "nvim-lua/plenary.nvim"},
      config = function()
        require"startup".setup()
      end
    },


    -- Optionally: Add prettier for JS/TS/HTML/CSS formatting
    use "prettier/vim-prettier",

    use "morhetz/gruvbox",

    -- Auto-completion for flutter
    use {
        'hrsh7th/nvim-cmp',
        requires = {
            'hrsh7th/cmp-nvim-lsp',
            'hrsh7th/cmp-buffer',
            'hrsh7th/cmp-path',
            'hrsh7th/cmp-cmdline',
            'hrsh7th/vim-vsnip',
        }
    },
    
    use 'lewis6991/hover.nvim', 

    use 'mbbill/undotree',
    use 'ray-x/go.nvim',
    use 'ray-x/guihua.lua', -- recommended if need floating window support

    use "hrsh7th/cmp-nvim-lsp", -- LSP completion source
    use "L3MON4D3/LuaSnip",     -- Optional snippet engine
    use "saadparwaiz1/cmp_luasnip",

    use {
        "leoluz/nvim-dap-go",
        requires = "mfussenegger/nvim-dap",
        config = function()
            require("dap-go").setup()
        end
    }
}
end)
