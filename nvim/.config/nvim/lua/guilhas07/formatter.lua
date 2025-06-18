local function add_prettier()
	local formatters = {}
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
		-- added so it supports go templates. however the go template plugin needs to be added to
		-- .prettier.json
		"htmlangular",
	}

	for _, ft in pairs(supported) do
		formatters[ft] = { "prettier" }
	end
	return formatters
end

local formatters_by_ft = {
	lua = { "stylua" },
	rust = { "rustfmt" },
}

formatters_by_ft = vim.tbl_extend("error", formatters_by_ft, add_prettier())

require("conform").setup({
	formatters_by_ft = formatters_by_ft,
	format_on_save = {
		lsp_format = "fallback",
		timeout_ms = 500,
	},
})
