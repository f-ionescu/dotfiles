" --- General ---
set nocompatible        " Disable vi compatibility; required before plugins load
syntax on               " Enable syntax highlighting

" --- Display ---
set number              " Show absolute line number on current line
set relativenumber      " Show relative numbers on other lines
set laststatus=2        " Always show the statusline
set t_Co=256            " Use 256 terminal colors

" --- Plugins (vim-plug) ---
call plug#begin()

Plug 'tpope/vim-sensible'               " Sensible baseline defaults
Plug 'junegunn/fzf'                     " Fuzzy finder core
Plug 'junegunn/fzf.vim'                 " Vim commands for fzf (:Files, :Rg, ...)
Plug 'vim-airline/vim-airline'          " Statusline
Plug 'vim-airline/vim-airline-themes'   " Airline themes
Plug 'nordtheme/vim'                    " Nord colorscheme

call plug#end()

" --- Colors (must come after plug#end) ---
colorscheme nord                        " Apply Nord theme
highlight Comment ctermfg=146 guifg=#D3D3D3   " Lighter comment color

" --- Airline ---
let g:airline_powerline_fonts = 1             " Use Nerd Font glyphs
let g:airline#extensions#tabline#enabled = 1  " Show buffers/tabs in top bar
