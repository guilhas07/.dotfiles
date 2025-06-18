local function add_prettier()
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

	local formatters_by_ft = {}
	for _, ft in ipairs(supported) do
		formatters_by_ft[ft] = { "prettier" }
	end
	return { formatters_by_ft = formatters_by_ft }
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
