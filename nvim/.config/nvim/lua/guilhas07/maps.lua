local keymap = vim.keymap
local opts = { noremap = true, silent = true }

keymap.set("n", "<leader>u", vim.cmd.UndotreeToggle, opts)
keymap.set("n", "<leader>pv", vim.cmd.Oil, opts)
keymap.set("n", "<leader>ng", vim.cmd.Neogen, opts)
keymap.set("n", "<leader>z", vim.cmd.Zen, opts)

keymap.set("v", "J", ":m '>+1<CR>gv=gv")
keymap.set("v", "K", ":m '<-2<CR>gv=gv")
keymap.set("n", "<leader>f", function()
	require("conform").format({ async = true }, function(err)
		vim.notify("Formatting...")
		if not err then
			local mode = vim.api.nvim_get_mode().mode
			if vim.startswith(string.lower(mode), "v") then
				vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "n", true)
			end
		end
	end)
end, { desc = "Format code" })

-- keymap.set("n", "<c-d>", "<c-d>zz", opts)
-- keymap.set("n", "<c-u>", "<c-u>zz", opts)
-- keymap.set("n", "n", "nzz", opts)
-- keymap.set("n", "N", "Nzz", opts)
