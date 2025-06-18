local utils = require("guilhas07.lsp.utils")
local on_attach = utils.on_attach
local servers = utils.servers

-- Get server capabilities
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = vim.tbl_deep_extend("force", capabilities, require("cmp_nvim_lsp").default_capabilities())

-- Setup LSP servers
local lspconfig = require("lspconfig")

local setup_server = function(server, config)
	config = vim.tbl_deep_extend("force", {
		on_attach = on_attach,
		capabilities = capabilities,
	}, config)
	lspconfig[server].setup(config)
end

for server, config in pairs(servers) do
	setup_server(server, config)
end
