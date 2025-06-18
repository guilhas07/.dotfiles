"Comments in vim dont close
"For inline comments add a pipe(|) before double quote


syntax on 
"Stops error sounds
set noerrorbells 
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
"Case sensetive searching until adding capital letter
"set smartcase
"No swap files and no backup
set noswapfile nobackup
"Because of that add a undo dir
set undodir=~/.vim/undodir
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

" ColorSchemes
Plug 'gruvbox-community/gruvbox'
Plug 'tomasr/molokai'

" Provide hooks to lsp
Plug 'jose-elias-alvarez/null-ls.nvim'

" Lsp
Plug 'neovim/nvim-lspconfig'

" Provide installation for Lsp, DAP, Lint, Formatter
Plug 'williamboman/mason.nvim'
Plug 'williamboman/mason-lspconfig.nvim'


" Snips
Plug 'L3MON4D3/LuaSnip'
Plug 'saadparwaiz1/cmp_luasnip'
Plug 'rafamadriz/friendly-snippets'

" Cmp
Plug 'hrsh7th/nvim-cmp'
Plug 'hrsh7th/cmp-buffer'
Plug 'hrsh7th/cmp-path'
Plug 'hrsh7th/cmp-nvim-lua'
Plug 'hrsh7th/cmp-nvim-lsp'

"vscode-like pictograms to neovim built-in lsp
Plug 'onsails/lspkind-nvim'

"Treesitter
Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}

" Telescope
Plug 'nvim-telescope/telescope.nvim'
Plug 'nvim-telescope/telescope-fzf-native.nvim', {'do': 'make'}

"Icons
Plug 'kyazdani42/nvim-web-devicons'

call plug#end()

let mapleader=" " 
lua require("guilhas07")

"--------------Style--------------
colorscheme gruvbox 

hi CursorLine guibg=none
hi SignColumn guibg=none
hi CursorLineNR guibg=none
hi LineNr guifg=#5eacd3
