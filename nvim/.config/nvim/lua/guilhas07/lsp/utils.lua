local border = "rounded"

local signs = {
	Error = " ",
	Warn = " ",
	Hint = " ",
	Info = " ",
}

for type, icon in pairs(signs) do
	local hl = "DiagnosticSign" .. type
	vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
end

vim.diagnostic.config({
	virtual_text = { prefix = "●" },
	float = { --[[ source = "always", ]]
		border = border,
	},
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
	if vim.tbl_islist(result) then
		vim.lsp.util.jump_to_location(result[1], client.offset_encoding)
	else
		vim.lsp.util.jump_to_location(result, client.offset_encoding)
	end
end

-- print("giro" .. vim.fs.find(".venv", {
-- 	upward = true,
-- 	stop = vim.uv.os_homedir(),
-- 	path = vim.fs.dirname(vim.api.nvim_buf_get_name(0)),
-- 	type = "directory",
-- })[1])

local function find(path, type)
	return vim.fs.find(path, {
		upward = true,
		stop = vim.uv.os_homedir(),
		path = vim.fn.getcwd(),
		type = type,
	})[1]
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
	-- eslint = {},
	-- tsserver = {},
	clangd = {},
	gopls = {
		settings = {
			gopls = {
				["ui.inlayhint.hints"] = {
					compositeLiteralFields = true,
					constantValues = true,
					parameterNames = true,
				},
			},
		},
	},
	-- jdtls = {
	--
	--    },
	pyright = {
		settings = {
			pyright = {
				-- Using Ruff's import organizer
				disableOrganizeImports = true,
			},
			python = {
				venv = ".venv",
				venvPath = vim.fs.dirname(find(".venv", "directory")) .. "/",
				analysis = {
					-- Ignore all files for analysis to exclusively use Ruff for linting
					-- ignore = { '*' },
				},
			},
		},
	},
	ruff_lsp = {},
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
}

local ensure_installed = {}
for i, _ in pairs(servers) do
	table.insert(ensure_installed, i)
end

-- Insure LSPs are installed
require("mason-lspconfig").setup({
	-- ensure_installed = ensure_installed,
})

-- Setup autoformmating
local augroup = vim.api.nvim_create_augroup("LspFormatting", {})
local lsp_formatting = function(bufnr)
	vim.lsp.buf.format({
		filter = function(client)
			return client.name ~= "tsserver"
		end,
		bufnr = bufnr,
		timeout_ms = 5000,
	})
end

local M = {}

-- LspAttach Function
function M.on_attach(client, bufnr)
	local bufopts = { noremap = true, silent = true, buffer = bufnr }
	vim.keymap.set("n", "K", vim.lsp.buf.hover, bufopts)
	vim.keymap.set("n", "gd", vim.lsp.buf.definition, bufopts)
	vim.keymap.set("n", "gt", vim.lsp.buf.type_definition, bufopts)
	vim.keymap.set("n", "gi", vim.lsp.buf.implementation, bufopts)
	vim.keymap.set("n", "<leader>sh", vim.lsp.buf.signature_help, bufopts)
	vim.keymap.set("n", "<leader>[d", vim.diagnostic.goto_next, bufopts)
	vim.keymap.set("n", "<leader>]d", vim.diagnostic.goto_prev, bufopts)
	vim.keymap.set("n", "<leader>r", vim.lsp.buf.rename, bufopts)
	vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, bufopts)
	vim.keymap.set("n", "<leader>f", lsp_formatting, bufopts)

	-- toggle inlay_hints
	if client.server_capabilities.inlayHintProvider then
		vim.keymap.set("n", "<leader>th", function()
			vim.lsp.inlay_hint.enable(bufnr, not vim.lsp.inlay_hint.is_enabled(bufnr))
		end)
	end
	if client.name == "ruff_lsp" then
		-- Disable hover in favor of Pyright
		client.server_capabilities.hoverProvider = false
	end
	-- auto formatting
	if client.supports_method("textDocument/formatting") then
		vim.api.nvim_clear_autocmds({ group = augroup, buffer = bufnr })
		vim.api.nvim_create_autocmd("BufWritePre", {
			group = augroup,
			buffer = bufnr,
			callback = function()
				lsp_formatting(bufnr)
			end,
		})
	end
end

-- Servers config
M.servers = servers

return M
