local border = "rounded"

local signs_hl = {
	[vim.diagnostic.severity.ERROR] = { " ", "Error" },
	[vim.diagnostic.severity.WARN] = { " ", "Warn" },
	[vim.diagnostic.severity.HINT] = { " ", "Hint" },
	[vim.diagnostic.severity.INFO] = { " ", "Info" },
}

local signs = {
	text = {},
	texthl = {},
	numhl = {},
}

for type, data in pairs(signs_hl) do
	local hl = "DiagnosticSign" .. data[2]
	signs.text[type] = data[1]
	signs.texthl[type] = hl
	signs.numhl[type] = hl
end

vim.diagnostic.config({
	virtual_text = { prefix = "●" },
	float = { --[[ source = "always", ]]
		border = border,
	},
	signs = signs,
})

require("lspconfig.ui.windows").default_options.border = border
require("mason").setup({ ui = { border = border } })

-- Configure handlers
vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, { border = border })
vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, { border = border })
vim.lsp.handlers["textDocument/definition"] = function(_, result, ctx)
	-- Always go to first definition
	if not result or vim.tbl_isempty(result) then
		print("[LSP]: No definition found")
		return
	end

	local client = vim.lsp.get_client_by_id(ctx.client_id)
	if client == nil then
		print("[LSP]: Couldn't get client with id " .. ctx.client_id)
		return
	end

	if vim.islist(result) then
		vim.lsp.util.jump_to_location(result[1], client.offset_encoding)
	else
		vim.lsp.util.jump_to_location(result, client.offset_encoding)
	end
end

local servers = {
	lua_ls = {
		settings = {
			Lua = {
				format = {
					enable = false,
				},
				hint = {
					enable = true,
					setType = true,
					arrayIndex = "Disable",
				},
				runtime = {
					version = "LuaJIT",
				},
				workspace = {
					library = vim.api.nvim_get_runtime_file("", true),
					checkThirdParty = false,
				},
				diagnostics = {
					globals = { "vim" },
				},
			},
		},
	},
	lemminx = {},
	-- ts_ls = {},
	vue_ls = {},
	vtsls = {
		filetypes = { "typescript", "javascript", "javascriptreact", "typescriptreact", "vue" },
		settings = {
			vtsls = {
				tsserver = {
					globalPlugins = {
						{
							name = "@vue/typescript-plugin",
							location = vim.fn.stdpath("data")
								.. "/mason/packages/vue-language-server/node_modules/@vue/language-server",
							languages = { "vue" },
							configNamespace = "typescript",
							enableForWorkspaceTypeScriptVersions = true,
						},
					},
				},
			},
		},
	},
	clangd = {},
	gopls = {
		settings = {
			gopls = {
				["ui.inlayhint.hints"] = {
					compositeLiteralFields = true,
					constantValues = true,
					parameterNames = true,
					rangeVariableTypes = true,
				},
				["ui.diagnostic.staticcheck"] = true,
				gofumpt = true,
			},
		},
	},
	templ = {},
	-- jdtls = {
	--
	--    },
	eslint = {},
	pyright = {
		settings = {
			pyright = {
				-- Using Ruff's import organizer
				disableOrganizeImports = true,
			},
			python = {
				venv = ".venv",
				venvPath = (function()
					local path = vim.fs.find(".venv", {
						upward = true,
						stop = vim.uv.os_homedir(),
						path = vim.fn.getcwd(),
						type = "directory",
					})[1]
					return path ~= nil and (vim.fs.dirname(path) .. "/") or nil
				end)(),
				analysis = {
					ignore = { ".venv" },
				},
			},
		},
	},
	ruff = {},
	-- html = {},
	-- cssls = {},
	-- perlnavigator = {},
	-- bashls = {},
	-- omnisharp_mono = {
	--     -- settings = {
	--     --     omnisharp = {
	--     --         path = "latest",
	--     --         useModernNet = false,
	--     --     },
	--     -- },
	--     handlers = {
	--         ["textDocument/definition"] = require("omnisharp_extended").handler,
	--     },
	-- },
	omnisharp = {
		--     useModernNet = false,
		--     settings = {
		--         useModernNet = false,
		--         omnisharp = {
		--             path = "latest",
		--             useModernNet = false,
		--         },
		--     },
		handlers = {
			["textDocument/definition"] = require("omnisharp_extended").handler,
		},
	},
	-- sqls = {
	-- 	settings = {
	-- 		sqls = {
	-- 			connections = { { driver = "sqlite3", dataSourceName = "/home/guilherme/teste.db" } },
	-- 		},
	-- 	},
	-- },
}

local M = {}

-- LspAttach Function
function M.on_attach(client, bufnr)
	local bufopts = { noremap = true, silent = true, buffer = bufnr }
	vim.keymap.set("n", "K", vim.lsp.buf.hover, bufopts)
	vim.keymap.set("n", "gd", vim.lsp.buf.definition, bufopts)
	vim.keymap.set("n", "gt", vim.lsp.buf.type_definition, bufopts)
	vim.keymap.set("n", "gi", vim.lsp.buf.implementation, bufopts)
	vim.keymap.set("n", "<leader>sh", vim.lsp.buf.signature_help, bufopts)
	vim.keymap.set("n", "<leader>r", vim.lsp.buf.rename, bufopts)
	vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, bufopts)

	-- toggle inlay_hints
	if client.server_capabilities.inlayHintProvider then
		vim.lsp.inlay_hint.enable(true, nil)
		vim.keymap.set("n", "<leader>th", function()
			vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled(), nil)
		end)
		require("guilhas07.autocmd").inlay_hint(bufnr)
	end
	if client.name == "ruff" then
		-- Disable hover in favor of Pyright
		client.server_capabilities.hoverProvider = false
	end
	-- auto formatting
	-- if client.supports_method("textDocument/formatting") then
	-- 	vim.api.nvim_clear_autocmds({ group = augroup, buffer = bufnr })
	-- 	vim.api.nvim_create_autocmd("BufWritePre", {
	-- 		group = augroup,
	-- 		buffer = bufnr,
	-- 		callback = function()
	-- 			lsp_formatting(bufnr)
	-- 		end,
	-- 	})
	-- end
end

-- Servers config
M.servers = servers

return M
