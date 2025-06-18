local lint = require("lint")
vim.api.nvim_create_autocmd({ "BufWritePost", "BufReadPost", "InsertLeave" }, {
	callback = function()
		-- try_lint without arguments runs the linters defined in `linters_by_ft`
		-- for the current filetype
		lint.try_lint(nil, { ignore_errors = true })

		local skip_fts = { "oil", "TelescopePrompt", "TelescopeResults" }
		if vim.iter(skip_fts):any(function(el)
			return el == vim.bo.filetype
		end) then
			return
		end

		require("lint").try_lint("cspell")
	end,
})
