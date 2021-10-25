syntax enable
filetype plugin on

if has("gui_running")
	set background=light
	colorscheme solarized
	set t_Co=16
endif

set number
set cursorline
set showmatch
set incsearch
set hlsearch

let mapleader=","

set rtp+=~/.vim/plugins/vim-sneak
helptags ~/.vim/plugins/vim-sneak/doc
let g:sneak#s_next = 1 " Pressing s again will go to the next sneak

set rtp+=~/.vim/plugins/vim-surround
helptags ~/.vim/plugins/vim-surround/doc

set rtp+=~/.vim/plugins/vim-repeat

set rtp+=~/.vim/plugins/vim-easymotion
helptags ~/.vim/plugins/vim-easymotion/doc

