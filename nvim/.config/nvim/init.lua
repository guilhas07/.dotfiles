vim.g.mapleader = " "

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		"--branch=stable", -- latest stable release
		lazypath,
	})
end
vim.opt.rtp:prepend(lazypath)

require("guilhas07.set")
require("guilhas07.remaps")

require("lazy").setup({

	{ dir = "~/test.nvim/", config = true },
	{
		"stevearc/oil.nvim",
		-- Optional dependencies
		dependencies = { "nvim-tree/nvim-web-devicons" },
		opts = {
			keymaps = {
				["<C-p>"] = false,
			},
			view_options = {
				show_hidden = true,
			},
		},
	},
	{ "folke/zen-mode.nvim", config = true },
	{
		"ThePrimeagen/harpoon",
		branch = "harpoon2",
		dependencies = { "nvim-lua/plenary.nvim" },
		config = function()
			require("guilhas07.harpoon")
		end,
	},
	{
		"rcarriga/nvim-notify",
		init = function()
			vim.notify = require("notify")
		end,
		opts = {
			stages = "static",
			render = "minimal",
		},
	},
	-- Comments
	{ "numToStr/Comment.nvim", config = true },
	{
		"m4xshen/hardtime.nvim",
		dependencies = {
			"MunifTanjim/nui.nvim",
			"nvim-lua/plenary.nvim",
			"rcarriga/nvim-notify",
		},
		opts = {
			disable_mouse = false,
			allow_different_key = true,
			max_time = 500,
			restricted_keys = {
				["<C-P>"] = {},
			},
			hints = {
				["[bB][eE]"] = {
					message = function(keys)
						return "Use g" .. keys:sub(2) .. " instead of " .. keys
					end,
					length = 2,
				},
			},
		},
	},
	--AutoPairs
	-- { "windwp/nvim-autopairs", config = true },
	{
		-- Add indentation guides even on blank lines
		"lukas-reineke/indent-blankline.nvim",
		opts = {
			indent = {
				char = "┊",
			},
		},
		--     show_trailing_blankline_indent = false,
		-- },
		main = "ibl",
		event = "VeryLazy",
	},
	{
		-- Adds git releated signs to the gutter, as well as utilities for managing changes
		"lewis6991/gitsigns.nvim",
		opts = {
			signs = {
				add = { text = "+" },
				change = { text = "~" },
				delete = { text = "_" },
				topdelete = { text = "‾" },
				changedelete = { text = "~" },
			},
		},
	},
	{
		-- Lsp
		"neovim/nvim-lspconfig",
		dependencies = {
			-- Provide installation for Lsp, DAP, Lint, Formatter
			"williamboman/mason.nvim",
			"williamboman/mason-lspconfig.nvim",
			"jose-elias-alvarez/null-ls.nvim", -- Provide hooks to lsp
			-- { "j-hui/fidget.nvim", opts = { window = { blend = 0 } } },
			"mfussenegger/nvim-jdtls",
			{
				"mrcjkb/rustaceanvim",
				version = "^3", -- Recommended
				ft = { "rust" },
				config = function()
					vim.g.rustaceanvim = {
						server = {
							on_attach = require("guilhas07.lsp.utils").on_attach,
						},
					}
				end,
			},
		},
		config = function()
			require("guilhas07.lsp")
		end,
	},
	"Hoffs/omnisharp-extended-lsp.nvim",
	{
		-- CMP
		"hrsh7th/nvim-cmp",
		dependencies = {
			"hrsh7th/cmp-nvim-lsp",
			"hrsh7th/cmp-nvim-lua",
			"hrsh7th/cmp-buffer",
			"hrsh7th/cmp-path",
			"hrsh7th/cmp-nvim-lsp-signature-help",
			"onsails/lspkind-nvim", -- icons to cmp
			"saadparwaiz1/cmp_luasnip",
			"L3MON4D3/LuaSnip",
		},
		config = function()
			require("guilhas07.cmp")
		end,
	},
	{
		-- Snips
		"L3MON4D3/LuaSnip",
		dependencies = "rafamadriz/friendly-snippets",
		config = function()
			require("guilhas07.snippet")
		end,
	},

	{
		--Treesitter
		-- dir = "~/nvim-treesitter/",
		"nvim-treesitter/nvim-treesitter",
		dependencies = {
			{
				"nvim-treesitter/nvim-treesitter-context",
				opts = {
					-- max_lines = 5,
					separator = "-",
				},
			},
		},
		build = ":TSUpdate",
		config = function()
			require("guilhas07.treesitter")
		end,
	},
	{
		-- Telescope
		"nvim-telescope/telescope.nvim",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"nvim-telescope/telescope-fzf-native.nvim",
		},
		config = function()
			require("guilhas07.telescope")
		end,
	},

	{ "nvim-telescope/telescope-fzf-native.nvim", build = "make" },

	-- Provides vim.ui.input and select overrides
	"stevearc/dressing.nvim",

	--Icons
	"kyazdani42/nvim-web-devicons",

	-- Status Line
	{ "nvim-lualine/lualine.nvim", config = true },

	-- ColorSchemes
	"ellisonleao/gruvbox.nvim",
	"tomasr/molokai",
	"olimorris/onedarkpro.nvim",
	{ "rose-pine/neovim", name = "rose-pine" },
	{ "catppuccin/nvim", name = "catppuccin" },
	"folke/tokyonight.nvim",
	"rebelot/kanagawa.nvim",
	-- 'norcalli/nvim-colorizer,
	"mbbill/undotree",
}, { ui = { border = "rounded" }, checker = { enabled = true } })
