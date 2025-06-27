-- require("nvim-treesitter.configs").setup({
-- 	-- ensure_installed = "all",
-- 	highlight = { enable = true },
-- 	indent = { enable = true },
-- 	auto_install = true,
-- 	--incremental_selection = { enable = true },
-- 	--textobjects = { enable = true }
-- })

vim.keymap.set("n", "[c", function()
	require("treesitter-context").go_to_context(vim.v.count1)
end, { silent = true })
