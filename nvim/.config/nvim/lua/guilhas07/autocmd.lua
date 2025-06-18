local group = "guilhas07"

vim.api.nvim_create_autocmd("TextYankPost", {
	desc = "Highlight when yanking (copying) text",
	group = vim.api.nvim_create_augroup(group .. ":Highlight_on_yank", {}),
	callback = function()
		vim.highlight.on_yank()
	end,
})
