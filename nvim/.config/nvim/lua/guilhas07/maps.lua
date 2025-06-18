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

keymap.set("n", "<leader>cd", function()
	local qf = vim.w.quickfix_title and vim.api.nvim_get_current_buf()
	if not qf then
		for _, win in pairs(vim.fn.getwininfo()) do
			if win.quickfix == 1 then
				qf = win.bufnr
			end
		end
	end

	vim.ui.input({ prompt = "Enter command for cdo: ", relative = "editor" }, function(input)
		if not input or input == "" then
			return
		end

		local bufs = vim.iter(vim.api.nvim_list_bufs()):filter(vim.api.nvim_buf_is_loaded):fold({}, function(acc, v)
			acc[v] = true
			return acc
		end)

		-- NOTE: creating another win where buffers are going to be modified by cdo.
		-- when deleting them this preserves the original layout
		vim.api.nvim_open_win(0, true, { relative = "win", row = 0, col = 0, width = 1, height = 1 })
		vim.cmd("silent noautocmd cdo " .. input .. " | update")
		vim.iter(vim.api.nvim_list_bufs()):filter(vim.api.nvim_buf_is_loaded):each(function(buf)
			if not bufs[buf] or buf == qf then
				vim.cmd("bwipeout " .. buf)
			end
		end)
	end)
end, { desc = "Cdo without autocmds" })

-- keymap.set("n", "<c-d>", "<c-d>zz", opts)
-- keymap.set("n", "<c-u>", "<c-u>zz", opts)
-- keymap.set("n", "n", "nzz", opts)
-- keymap.set("n", "N", "Nzz", opts)
