local function add_prettier()
	local prettier_settings = {
		formatters_by_ft = {},
		formatters = {
			prettier = {
				require_cwd = true,
				condition = function(self, ctx)
					return vim.fs.root(ctx.dirname, ".eslintrc.js") == nil
				end,
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

local opts = {
	formatters_by_ft = {
		lua = { "stylua" },
		rust = { "rustfmt" },
	},
}

opts = vim.tbl_deep_extend("keep", opts, add_prettier())
require("conform").setup(opts)

vim.api.nvim_create_autocmd("BufWritePre", {
	pattern = "*",
	callback = function(args)
		require("conform").format({
			bufnr = args.buf,
			async = true,
			lsp_format = "fallback",
			filter = function(client)
				function check_client()
					local clients = vim.lsp.get_clients({ buffer = args.buf })
					for _, c in pairs(clients) do
						if c.name == "eslint" then
							return client.name == "eslint"
						end
					end
					-- don't use ts_ls if other lsp is attached
					if client.name == "ts_ls" then
						return #clients == 1
					end
					return true
				end
				local useClient = check_client()
				-- print("Checking " .. client.name .. " Using: " .. tostring(useClient))
				return useClient
			end,
		})
	end,
})
