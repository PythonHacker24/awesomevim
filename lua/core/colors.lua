-- ============================================================================
-- Colorscheme with persistence: remembers the last :colorscheme across runs
-- ============================================================================

local persist_file = vim.fn.stdpath("data") .. "/colorscheme"

local function save_colorscheme(name)
    vim.fn.writefile({ name }, persist_file)
end

local function load_colorscheme()
    if vim.fn.filereadable(persist_file) == 1 then
        local lines = vim.fn.readfile(persist_file)
        if lines and lines[1] and lines[1] ~= "" then
            return lines[1]
        end
    end
    return "gruvbox"
end

function ColorMyPencils(color)
    color = color or load_colorscheme()
    vim.cmd.colorscheme(color)
end

vim.api.nvim_create_autocmd("ColorScheme", {
    callback = function()
        save_colorscheme(vim.g.colors_name)
    end,
})

ColorMyPencils()
