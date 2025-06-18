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
