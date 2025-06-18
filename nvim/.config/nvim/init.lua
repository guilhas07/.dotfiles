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

require("lazy").setup({
    -- Comments
    { "numToStr/Comment.nvim", config = true },

    -- AutoPairs
    { "windwp/nvim-autopairs", config = true },

    {
        -- Lsp
        "neovim/nvim-lspconfig",
        dependencies = {
            -- Provide installation for Lsp, DAP, Lint, Formatter
            "williamboman/mason.nvim",
            "williamboman/mason-lspconfig.nvim",
            "jose-elias-alvarez/null-ls.nvim", -- Provide hooks to lsp
            { "j-hui/fidget.nvim", config = true },
            { "folke/neodev.nvim", config = true },
        },
        config = function()
            require("guilhas07.lsp")
        end,
        -- "mfussenegger/nvim-jdtls",
    },

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
        "nvim-treesitter/nvim-treesitter",
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
    { "nvim-lualine/lualine.nvim",                config = true },

    -- ColorSchemes
    "ellisonleao/gruvbox.nvim",
    "tomasr/molokai",
    "olimorris/onedarkpro.nvim",
    { "rose-pine/neovim", name = "rose-pine" },
    "folke/tokyonight.nvim",

    -- 'norcalli/nvim-colorizer.lua',
    "mbbill/undotree",
}, { ui = { border = "rounded" } })

require("guilhas07.set")
require("guilhas07.remaps")
