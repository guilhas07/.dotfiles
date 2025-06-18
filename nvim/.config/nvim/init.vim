"Comments in vim dont close
"For inline comments add a pipe(|) before double quote

"set foldmethod=expr
"set foldexpr=nvim_treesitter#foldexpr()
"4 tab and 4 spaces and 4 >>
set tabstop=4 softtabstop=4 shiftwidth=4 
"Converts tab to spaces
set expandtab
"Smart Indent
set smartindent
"Set line numbers and relative numbers
set nu relativenumber
"No wrap
set nowrap
"No swap files and no backup
set noswapfile nobackup
"Creates undo file
set undofile
"Get results while searching and stop highlight after founding word
set incsearch nohlsearch 
"Keeps buffer in background
set hidden
"Keeps cursor in the center while scrolling down/up
set scrolloff=8

set termguicolors

set showcmd

set signcolumn=yes

set updatetime=50

set cursorline

" Don't pass messages to |ins-completion-menu|.
set shortmess+=c

set completeopt=menu,menuone,noselect

"Plugins
call plug#begin('~/.vim/plugged')

" Dependency for multiple plugins 
Plug 'nvim-lua/plenary.nvim' 

" Provide installation for Lsp, DAP, Lint, Formatter
Plug 'williamboman/mason.nvim'
Plug 'williamboman/mason-lspconfig.nvim'

" Lsp
Plug 'neovim/nvim-lspconfig'
Plug 'onsails/lspkind-nvim'

" Provide hooks to lsp
Plug 'jose-elias-alvarez/null-ls.nvim'

" Cmp
Plug 'hrsh7th/nvim-cmp'
Plug 'hrsh7th/cmp-buffer'
Plug 'hrsh7th/cmp-path'
Plug 'hrsh7th/cmp-nvim-lua'
Plug 'hrsh7th/cmp-nvim-lsp'
Plug 'hrsh7th/cmp-nvim-lsp-signature-help'

" AutoPairs
Plug 'windwp/nvim-autopairs'

" Snips
Plug 'L3MON4D3/LuaSnip'
Plug 'saadparwaiz1/cmp_luasnip'
Plug 'rafamadriz/friendly-snippets'

"Treesitter
Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}

" Telescope
Plug 'nvim-telescope/telescope.nvim'
Plug 'nvim-telescope/telescope-fzf-native.nvim', {'do': 'make'}

" Provides vim.ui.input and select overrides
Plug 'stevearc/dressing.nvim'

"Icons
Plug 'kyazdani42/nvim-web-devicons'

" Comments
Plug 'numToStr/Comment.nvim'

" Status Line
Plug 'nvim-lualine/lualine.nvim'

" ColorSchemes
" Plug 'gruvbox-community/gruvbox'
Plug 'ellisonleao/gruvbox.nvim'
Plug 'tomasr/molokai'

"Plug 'norcalli/nvim-colorizer.lua'
Plug 'mbbill/undotree'

call plug#end()
let mapleader=" "
lua require("guilhas07")
