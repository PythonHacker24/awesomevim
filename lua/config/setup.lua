local function setup_packer()
    -- Load packer
    local packer = require('packer')

    -- Source packer configuration
    local packer_path = vim.fn.stdpath('config') .. '/custom/packer.lua'
    vim.cmd('luafile ' .. packer_path)

    -- Run PackerSync
    packer.sync()
end

-- Run the setup function
setup_packer()

