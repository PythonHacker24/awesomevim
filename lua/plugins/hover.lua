require("hover").setup({
    init = function()
        require("hover.providers.lsp")
    end,
    preview_opts = {
        border = 'single'
    },
    preview_window = false,
    title = true,
    mouse_providers = { 'LSP' },
    mouse_delay = 1000
})
