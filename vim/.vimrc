colorscheme ron
set number              " show line numbers
set wildmenu            " visual autocomplete for command menu
set showmatch           " highlight matching [{()}]
set incsearch           " search as characters are entered
set hlsearch            " highlight matches
set ignorecase		    " Use case case insensitive search
set smartcase		    " case insensetive search except when using capital letters
set mouse=a		        " Enable use of the mouse for all modes
set laststatus=2	    " Status bar
syntax on
filetype plugin on
filetype indent on


" custom key bindings
xnoremap <C-c> y:call system("wl-copy", @")<cr>