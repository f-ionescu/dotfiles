set laststatus=2
set rnu nu
syntax on

set rtp+=$HOME/Library/Python/3.9/lib/python/site-packages/powerline/bindings/vim
set t_Co=256

"vim-plug
call plug#begin()

Plug 'tpope/vim-sensible'
Plug 'junegunn/fzf'
Plug 'junegunn/fzf.vim'

call plug#end()
