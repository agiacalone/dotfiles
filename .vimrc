set nocompatible		"use vim defaults
set t_Co=256			"set vim to use 256 colors
filetype plugin indent on	"make use of language-specific indentations
set noshowmode
set ls=2			"always show status line
set tabstop=4			"numbers of spaces of tab character
set softtabstop=4		"change the spaces of tabs while editing
set shiftwidth=4		"number of spaces to (auto)indent
set scrolloff=3			"keep 3 lines when scrolling
"set expandtab			"use spaces instead of tabs
set showcmd			"display incomplete commands
set hlsearch			"highlight searches
set incsearch			"do incremental searches
set ruler			"show the cursor position all the time
set nobackup			"do not keep a backup file
set ignorecase			"ignore case when searching
set title			"show title in console title bar
set ttyfast			"smoother changes
set modeline			"last lines in document sets vim mode
set modelines=3			"number of lines checked for modelines
set shortmess=atI		"abbreviate messages
set nostartofline		"don't jump to the first character when paging
set wrap			"word wrap on
set linebreak			"keep words intact on the same line when breaking
set textwidth=0			"turn off hard wrapping
set colorcolumn=80		"show a line at 80 characters
set whichwrap=b,s,h,l,<,>,[,]	"move freely between files
set autoindent			"always set autoindent on
set smartindent			"smart indent
set number			"add line numbers on the left
set background=dark		"force the background color
set wildmenu			"visual autocomplete for command menu
set showmatch			"show matching [{()}]
set foldenable			"enable text folding
set foldlevelstart=10		"open most folds by default
set foldnestmax=10		"don't let folds get too crazy
set foldmethod=indent		"fold based on indent level
set cursorline			"highlight the current line
set noswapfile			"disable swapfile
syntax enable			"syntax highlighting on
set bs=2			"backspace fix for some systems

" Allow for true colors
if (has("termguicolors"))
    set termguicolors
endif

" Allow for italics
let &t_ZH="\e[3m"
let &t_ZR="\e[23m"

" Vundle Plugins and Settings
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()
Plugin 'VundleVim/Vundle.vim'
Plugin 'itchyny/lightline.vim'
Plugin 'lesliev/vim-inform7'
Plugin 'godlygeek/tabular'
Plugin 'plasticboy/vim-markdown'
Plugin 'trusktr/seti.vim'
Plugin 'junegunn/vim-journal'
Plugin 'tpope/vim-surround'
Plugin 'gsiano/vmux-clipboard'
Plugin 'w0rp/ale'
Plugin 'lervag/vimtex'
Plugin 'haishanh/night-owl.vim'
Plugin 'preservim/nerdtree'
Plugin 'tiagofumo/vim-nerdtree-syntax-highlight'
Plugin 'tpope/vim-obsession'
Plugin 'dhruvasagar/vim-prosession'
Plugin 'tpope/vim-fugitive'
Plugin 'airblade/vim-gitgutter'
Plugin 'Yggdroot/indentLine'
Plugin 'mhinz/vim-startify'
Plugin 'SirVer/ultisnips'
Plugin 'honza/vim-snippets'
call vundle#end()

" Settings for vim-tex
let g:tex_flavor = 'latex'

" Settings for Ale Linter
let g:ale_completion_enabled = 1

" Night Owl theme
let $NVIM_TUI_ENABLE_TRUE_COLOR=1
let g:lightline = { 'colorscheme': 'nightowl' }
colorscheme night-owl

" GUI Specific Settings
if has("gui_running")
    set guifont=Hack\ Regular:h15
    set guioptions-=r
    set guioptions-=m
    set guioptions-=T
endif
