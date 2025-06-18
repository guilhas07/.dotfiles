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

require("lazy").setup({
    {
        "rcarriga/nvim-notify",
        config = function()
            local opts = {
                stages = "static",
                render = "minimal",
            }
            require("notify").setup(opts)
            vim.notify = require("notify")
        end,
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
            allow_different_key = true,
            max_time = 3000,
            restricted_keys = {
                ["<C-P>"] = {},
            },
        },
    },
    --AutoPairs
    { "windwp/nvim-autopairs", config = true },
    {
        -- Add indentation guides even on blank lines
        "lukas-reineke/indent-blankline.nvim",
        opts = {
            char = "┊",
            show_trailing_blankline_indent = false,
        },
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
            { "folke/neodev.nvim", config = true },
            "mfussenegger/nvim-jdtls",
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
        build = ":TSUpdate",
        dependencies = "nvim-treesitter/playground",
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
    { "nvim-lualine/lualine.nvim",                config = true },

    -- ColorSchemes
    "ellisonleao/gruvbox.nvim",
    "tomasr/molokai",
    "olimorris/onedarkpro.nvim",
    { "rose-pine/neovim", name = "rose-pine" },
    { "catppuccin/nvim",  name = "catppuccin" },
    "folke/tokyonight.nvim",
    "rebelot/kanagawa.nvim",
    -- 'norcalli/nvim-colorizer,
    "mbbill/undotree",
}, { ui = { border = "rounded" } })

require("guilhas07.remaps")
