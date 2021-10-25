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

set rtp+=~/.vim/plugins/vim-sneak
let g:sneak#s_next = 1 " Pressing s again will go to the next sneak
helptags ~/.vim/plugins/vim-sneak/doc

