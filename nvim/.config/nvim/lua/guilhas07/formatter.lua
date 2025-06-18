local function add_prettier()
	local prettier_settings = {
		formatters_by_ft = {},
		formatters = {
			prettier = {
				require_cwd = true,
				-- NOTE: Only activate prettier if one of these files is available
				cwd = require("conform.util").root_file({
					".prettierrc",
					".prettierrc.json",
					".prettierrc.yml",
					".prettierrc.yaml",
					".prettierrc.json5",
					".prettierrc.js",
					".prettierrc.cjs",
					".prettierrc.mjs",
					".prettierrc.toml",
					"prettier.config.js",
					"prettier.config.cjs",
					"prettier.config.mjs",
				}),
			},
		},
	}
	-- inspired by LazyVim: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/plugins/extras/formatting/prettier.lua
	local supported = {
		"css",
		"graphql",
		"handlebars",
		"html",
		"javascript",
		"javascriptreact",
		"json",
		"jsonc",
		"less",
		"markdown",
		"markdown.mdx",
		"scss",
		"typescript",
		"typescriptreact",
		"vue",
		"yaml",
		-- NOTE: added so it supports go templates. however the go template plugin needs to be added to
		-- .prettier.json
		"htmlangular",
	}

	for _, ft in pairs(supported) do
		prettier_settings["formatters_by_ft"][ft] = { "prettier" }
	end
	return prettier_settings
end

local settings = {
	formatters_by_ft = {
		lua = { "stylua" },
		rust = { "rustfmt" },
	},
}

settings = vim.tbl_deep_extend("keep", settings, add_prettier())
require("conform").setup(settings)

vim.api.nvim_create_autocmd("BufWritePre", {
	pattern = "*",
	callback = function(args)
		require("conform").format({
			bufnr = args.buf,
			async = true,
			lsp_format = "fallback",
			filter = function(client)
				-- don't use ts_ls if other lsp is attached
				if client.name == "ts_ls" then
					local clients = vim.lsp.get_clients({ buffer = args.buf })
					return #clients == 1
				end
				return true
			end,
		})
	end,
})
