" do not make vim compatible with vi.
set nocompatible

" tabs = 4 spaces
set tabstop=4

" show line numbers
set number
" show current position
set ruler
" highlight line cursor is on
set cursorline
" center cursor in screen
set scrolloff=999
" syntax highlighting
syntax on
" enable filetype plugins
filetype indent on
filetype plugin on
" highlight matching brace
set showmatch
" visual bell
set visualbell

" highlight all search results
set hlsearch
" smart-case search
set smartcase
" case-insensitive search
set ignorecase
" incremental search
set incsearch

" backspace behavior
set backspace=indent,eol,start
" show autocomplete menus
set wildmenu
set wildmode=list:longest
" autoread external file changes
set autoread
" no backups
set nobackup
set nowb
set noswapfile
