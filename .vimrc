syntax enable
filetype plugin on

if has("gui_running")
	set background=light
	colorscheme solarized
	set t_Co=16
endif

let g:ghc = "/usr/local/bin/ghc"
let g:haddock_browser = "/usr/bin/firefox"
au BufEnter *.hs compiler ghc
