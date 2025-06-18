vim.opt.nu = true
vim.opt.relativenumber = true

vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true

vim.opt.smartindent = true
vim.opt.breakindent = true

vim.opt.wrap = false

vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.undofile = true

vim.opt.hlsearch = false
vim.opt.incsearch = true

vim.opt.termguicolors = true

vim.opt.scrolloff = 8
vim.opt.signcolumn = "yes"
-- vim.opt.isfname:append("@-@") ?? n sei o que faz

vim.opt.updatetime = 50
vim.timeoutlen = 250

vim.o.completeopt = "menu,menuone,noselect"

vim.o.clipboard = "unnamedplus"

-- Don't pass messages to |ins-completion-menu|.
vim.opt_local.shortmess:append("c")
