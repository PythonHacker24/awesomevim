-- ============================================================================
-- LSP tooling: mason (server installer) and Go debugging
-- ============================================================================

require("mason").setup()
require("mason-lspconfig").setup()

require("dap-go").setup()
