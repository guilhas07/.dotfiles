-- Local options for typescript files
vim.opt_local.makeprg = "tsc %"
vim.keymap.set({"n"}, "<leader><c-s>", "<cmd>make<cr>", { silent = true })
