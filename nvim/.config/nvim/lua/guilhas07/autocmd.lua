local group = "guilhas07"

vim.api.nvim_create_autocmd("TextYankPost", {
	desc = "Highlight when yanking (copying) text",
	group = vim.api.nvim_create_augroup("Highlight_on_yank" .. group, { clear = true }),
	callback = function()
		vim.highlight.on_yank()
	end,
})

-- remove comment on new line
vim.api.nvim_create_autocmd("FileType", {
	group = vim.api.nvim_create_augroup("Format_options" .. group, { clear = true }),
	pattern = { "*" },
	callback = function()
		vim.opt.formatoptions:remove({ "o", "r" })
	end,
})
