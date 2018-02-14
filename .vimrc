set t_Co=256			"set vim to use 256 colors

filetype off
set nocompatible		"use vim defaults
set noshowmode
set ls=2				"always show status line
set tabstop=4			"numbers of spaces of tab character
set shiftwidth=4		"number of spaces to (auto)indent
set scrolloff=3			"keep 3 lines when scrolling
set expandtab			"use spaces instead of tabs
set showcmd				"display incomplete commands
set hlsearch			"highlight searches
set incsearch			"do incremental searches
set ruler				"show the cursor position all the time
"set visualbell t_vb	"turn off error beep/flash
set nobackup			"do not keep a backup file
set ignorecase			"ignore case when searching
"set noignorecase		"don't ignore case when searching
set title				"show title in console title bar
set ttyfast				"smoother changes
"set ttyscroll=0		"turn off scrolling
set modeline			"last lines in document sets vim mode
set modelines=3			"number of lines checked for modelines
set shortmess=atI		"abbreviate messages
set nostartofline		"don't jump to the first character when paging
set wrap				"word wrap on
set linebreak           "keep words intact on the same line when breaking
set textwidth=0         "turn off hard wrapping
"set spell               "automatic spell checking
"set nolist              "enable line break option
set whichwrap=b,s,h,l,<,>,[,]	"move freely between files
set autoindent			"always set autoindent on
set smartindent			"smart indent
set number              "add line numbers on the left
"set noautoindent		"turn off autoindent
set background=dark     "force the background color
set termguicolors
syntax enable			"syntax highlighting on
set bs=2                "backspace fix for some systems

" Set fonts for gVIM
if has("gui_running")
    set guifont=Source\ Code\ Pro\ 12
    set guioptions-=r
    set guioptions-=m
    set guioptions-=T
    colorscheme simple-dark
    if has("gui_macvim")
        set guifont=Source\ Code\ Pro:h14
        set transparency=5
    endif
endif

if has ("gui_vimr")
    "colorscheme dracula
endif

" Code for vundle
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()
Plugin 'VundleVim/Vundle.vim'
Plugin 'vim-airline/vim-airline'
Plugin 'vim-airline/vim-airline-themes'
Plugin 'lesliev/vim-inform7'
Plugin 'flazz/vim-colorschemes'
Plugin 'godlygeek/tabular'
Plugin 'plasticboy/vim-markdown'
Plugin 'morhetz/gruvbox'
Plugin 'dracula/vim'
Plugin 'trusktr/seti.vim'
Plugin 'reedes/vim-thematic'
Plugin 'reedes/vim-pencil'
Plugin 'tyrannicaltoucan/vim-quantum'
call vundle#end()            " required
filetype plugin indent on    " required

" Code for airline
let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#tabline#left_sep = ' '
let g:airline#extensions#tabline#left_alt_sep = '|'
let g:airline_powerline_fonts = 1
let g:airline_section_x = '%{PencilMode()}'
"let g:airline_theme='gruvbox'
let g:airline_theme='quantum'

" Code for Gruvbox
let g:gruvbox_termcolors = '256'
let g:gruvbox_contrast_dark = 'hard'

" Color schemes section
"colorscheme elflord
"colorscheme wombat
"colorscheme xoria256
"colorscheme inkpot
"colorscheme gardener
"colorscheme simple-dark
"colorscheme Tomorrow-Night-Eighties
"colorscheme Tomorrow-Night-Bright
"colorscheme ironman
"colorscheme coffee
"colorscheme matrix
"colorscheme gruvbox
"colorscheme dracula
"colorscheme seti
colorscheme quantum

"For solarized colors
"let g:solarized_termcolors=256
"colorscheme solarized
