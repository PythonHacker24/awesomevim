-- ============================================================================
-- Plugin declarations (packer.nvim)
--
-- Usage:
--   1. add a `use { ... }` entry below
--   2. :lua require("core.packer")
--   3. :PackerSync
--
-- install.sh bootstraps packer and runs a headless sync automatically.
-- ============================================================================

-- bootstrap packer on fresh installs
local ensure_packer = function()
    local install_path = vim.fn.stdpath("data") .. "/site/pack/packer/start/packer.nvim"
    if vim.fn.empty(vim.fn.glob(install_path)) > 0 then
        vim.fn.system({
            "git", "clone", "--depth", "1",
            "https://github.com/wbthomason/packer.nvim", install_path,
        })
        vim.cmd([[packadd packer.nvim]])
        return true
    end
    return false
end

local packer_bootstrap = ensure_packer()

vim.cmd([[packadd packer.nvim]])

return require("packer").startup(function(use)
    use "wbthomason/packer.nvim"

    -- finder
    use {
        "nvim-telescope/telescope.nvim", tag = "0.1.8",
        requires = { { "nvim-lua/plenary.nvim" } },
    }

    -- syntax and parsing
    use("nvim-treesitter/nvim-treesitter", { run = ":TSUpdate" })
    use "nvim-treesitter/playground"

    -- lsp, completion, formatting
    use {
        "williamboman/mason.nvim",
        "williamboman/mason-lspconfig.nvim",
        "neovim/nvim-lspconfig",
    }
    use {
        "nvimtools/none-ls.nvim",
        config = function()
            require("null-ls").setup()
        end,
        requires = { "nvim-lua/plenary.nvim" },
    }
    use {
        "hrsh7th/nvim-cmp",
        requires = {
            "hrsh7th/cmp-nvim-lsp",
            "hrsh7th/cmp-buffer",
            "hrsh7th/cmp-path",
            "hrsh7th/cmp-cmdline",
            "hrsh7th/vim-vsnip",
        },
    }
    use "L3MON4D3/LuaSnip"
    use "saadparwaiz1/cmp_luasnip"
    use "lewis6991/hover.nvim"
    use "prettier/vim-prettier"

    -- ui
    use {
        "nvim-tree/nvim-tree.lua",
        requires = { "nvim-tree/nvim-web-devicons" },
    }
    use {
        "nvim-lualine/lualine.nvim",
        requires = { "nvim-tree/nvim-web-devicons", opt = true },
    }
    use {
        "startup-nvim/startup.nvim",
        requires = { "nvim-telescope/telescope.nvim", "nvim-lua/plenary.nvim" },
    }
    use "karb94/neoscroll.nvim"

    -- themes
    use { "catppuccin/nvim", as = "catppuccin" }
    use "morhetz/gruvbox"

    -- editing helpers
    use { "akinsho/toggleterm.nvim", tag = "*" }
    use "mbbill/undotree"
    use {
        "numToStr/Comment.nvim",
        config = function()
            require("Comment").setup()
        end,
    }

    -- markdown rendering (used by the pi chat sidebar and markdown files)
    use {
        "MeanderingProgrammer/render-markdown.nvim",
        requires = { "nvim-treesitter/nvim-treesitter", "nvim-tree/nvim-web-devicons" },
        config = function()
            require("render-markdown").setup({
                enabled = false, -- disabled globally, toggled per buffer
            })
        end,
    }

    -- go development
    use "ray-x/go.nvim"
    use "ray-x/guihua.lua"
    use {
        "leoluz/nvim-dap-go",
        requires = "mfussenegger/nvim-dap",
    }

    if packer_bootstrap then
        require("packer").sync()
    end
end)
