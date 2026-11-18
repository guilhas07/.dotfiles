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
	signs = signs,
})

require("mason").setup()

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
				autoUseWorkspaceTsdk = true,
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
	},
	-- sqls = {
	-- 	settings = {
	-- 		sqls = {
	-- 			connections = { { driver = "sqlite3", dataSourceName = "/home/guilherme/teste.db" } },
	-- 		},
	-- 	},
	-- },
	jsonls = {},
	kotlin_lsp = {},
}

local M = {}

-- LspAttach Function
function M.on_attach(client, bufnr)
	local function map(lhs, rhs, desc)
		vim.keymap.set("n", lhs, rhs, { noremap = true, silent = true, buffer = bufnr, desc = desc })
	end
	if client.name == "omnisharp" then
		-- omnisharp-extended: same jumps, plus decompiled metadata / source-generated files
		local ox = require("omnisharp_extended")
		map("gd", ox.lsp_definition, "LSP definition (omnisharp)")
		map("grt", ox.lsp_type_definition, "LSP type definition (omnisharp)")
		map("grr", ox.lsp_references, "LSP references (omnisharp)")
		map("gri", ox.lsp_implementation, "LSP implementation (omnisharp)")
	else
		map("gd", vim.lsp.buf.definition, "LSP definition")
	end
	map("<leader>sh", vim.lsp.buf.signature_help, "LSP signature help")

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
