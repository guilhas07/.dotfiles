vim.opt.nu = true
vim.opt.relativenumber = true
vim.opt.cursorline = true

-- vim.opt.colorcolumn = "80"

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

--vim.opt.scrolloff = 8
vim.opt.scrolloff = 999
vim.opt.signcolumn = "yes"
-- vim.opt.isfname:append("@-@") ?? n sei o que faz

vim.opt.updatetime = 50
vim.timeoutlen = 250

vim.o.completeopt = "menu,menuone,noselect"

vim.o.clipboard = "unnamedplus"

if _G.IS_WSL then
	vim.g.clipboard = {
		name = "WslClipboard",
		copy = {
			["+"] = "clip.exe",
			["*"] = "clip.exe",
		},
		paste = {
			["+"] = 'powershell.exe -c [Console]::Out.Write($(Get-Clipboard -Raw).tostring().replace("`r", ""))',
			["*"] = 'powershell.exe -c [Console]::Out.Write($(Get-Clipboard -Raw).tostring().replace("`r", ""))',
		},
		cache_enabled = 0,
	}
end

vim.opt_local.shortmess:append("c")

vim.opt.foldmethod = "expr"
vim.opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
vim.opt.foldenable = false -- Use zi to toggle folds
vim.opt.foldtext = ""

vim.opt.virtualedit = "all"
vim.opt.startofline = false

vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"

vim.opt.guicursor = {
	"n-v-c-sm:block-Cursor/lCursor",
	"i-ci-ve:ver25-Cursor/lCursor",
	"r-cr-o:hor20-Cursor/lCursor",
}
-- vim.g.clipboard = {
--     name = 'Kitty',
--     copy = {
--         ['+'] = '| kitty +kitten clipboard',
--         ['*'] = '| kitty +kitten clipboard',
--     },
--     paste = {
--         ['+'] = 'kitty +kitten clipboard -g',
--         ['*'] = 'kitty +kitten clipboard -g',
--     },
--     cache_enabled = 0,
-- }
