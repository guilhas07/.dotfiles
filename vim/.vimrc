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
"Set line numbers and reletive numbers
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

set showcmd

"Plugins
call plug#begin('~/.vim/plugged')
Plug 'gruvbox-community/gruvbox'
Plug 'tomasr/molokai'
call plug#end()

let mapleader=" " 
"--------------Style--------------
set colorcolumn=80

colorscheme gruvbox "darkblue molokai 
"Placed under colorscheme to keep background none
"highlight Normal ctermbg=NONE 
highlight ColorColumn ctermbg=0 
"highlight Normal guibg=NONE 

