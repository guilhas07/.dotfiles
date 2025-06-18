local group = "guilhas07"

vim.filetype.add({
	extension = {
		templ = "templ",
	},
})

vim.api.nvim_create_autocmd("TermOpen", {
	group = vim.api.nvim_create_augroup(group .. ":Term ft", {}),
	callback = function()
		vim.cmd.set("filetype=term")
	end,
})

-- remove comment on new line
vim.api.nvim_create_autocmd("FileType", {
	group = vim.api.nvim_create_augroup(group .. ":Format_options", {}),
	pattern = { "*" },
	callback = function()
		vim.opt.formatoptions:remove({ "o", "r" })
	end,
})
