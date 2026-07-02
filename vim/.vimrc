set nocompatible      " required before plugins load (e.g. vim-airline's guard)
set laststatus=2
set rnu nu
syntax on

set t_Co=256

"vim-plug
call plug#begin()

Plug 'tpope/vim-sensible'
Plug 'junegunn/fzf'
Plug 'junegunn/fzf.vim'
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'

call plug#end()

" Statusline (vim-airline)
let g:airline_powerline_fonts = 1            " use Nerd Font glyphs (CodeNewRomanNFM)
let g:airline#extensions#tabline#enabled = 1 " show buffers/tabs in the top bar
