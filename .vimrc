set t_Co=256			"set vim to use 256 colors

filetype plugin on
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
set whichwrap=b,s,h,l,<,>,[,]	"move freely between files
set autoindent			"always set autoindent on
set smartindent			"smart indent
"set noautoindent		"turn off autoindent
set background=dark     "force the background color
syntax enable			"syntax highlighting on
set bs=2                "backspace fix for some systems

" Set fonts for gVIM
if has("gui_running")
    if has("gui_gtk2")
        set guifont=Inconsolata\ 12
    elseif has("gui_macvim")
        "set guifont=Source\ Code\ \Pro\ for\ Powerline:h14
        set guifont=Droid\ Sans\ Mono\ Dotted\ for\ Powerline:h14
    elseif has("gui_win32")
        set guifont=Consolas:h11:cANSI
    endif
endif

" Code for airline
execute pathogen#infect()
let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#tabline#left_sep = ' '
let g:airline#extensions#tabline#left_alt_sep = '|'
let g:airline_powerline_fonts = 1

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
colorscheme matrix

"For solarized colors
"let g:solarized_termcolors=256
"colorscheme solarized
