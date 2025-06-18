local keymap = vim.keymap
local opts = { noremap = true, silent = true }

keymap.set("n", "<leader>u", "<cmd>UndotreeToggle<cr>", opts)
keymap.set("n", "pv", vim.cmd.Ex, opts)
keymap.set("n", "<c-d>", "<c-d>zz", opts)
keymap.set("n", "<c-u>", "<c-u>zz", opts)
keymap.set("n", "n", "nzz", opts)
keymap.set("n", "N", "Nzz", opts)
