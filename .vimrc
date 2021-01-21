" General vim Settings
set t_Co=256			"set vim to use 256 colors
"set term=xterm-256color "set the term to xterm-256--may break some terms
filetype indent on      "make use of language-specific indentations
set nocompatible		"use vim defaults
set noshowmode
set ls=2				"always show status line
set tabstop=4			"numbers of spaces of tab character
set softtabstop=4       "change the spaces of tabs while editing
set shiftwidth=4		"number of spaces to (auto)indent
set scrolloff=3			"keep 3 lines when scrolling
"set expandtab			"use spaces instead of tabs
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
set colorcolumn=80      "show a line at 80 characters
"set spell              "automatic spell checking
"set nolist             "enable line break option
set whichwrap=b,s,h,l,<,>,[,]	"move freely between files
set autoindent			"always set autoindent on
set smartindent			"smart indent
set number              "add line numbers on the left
"set noautoindent		"turn off autoindent
set background=dark     "force the background color
set wildmenu            "visual autocomplete for command menu
set showmatch           "show matching [{()}]
set foldenable          "enable text folding
set foldlevelstart=10   "open most folds by default
set foldnestmax=10      "don't let folds get too crazy
set foldmethod=indent   "fold based on indent level
set cursorline          "highlight the current line
set showcmd             "show the last run command at the bottom
syntax enable			"syntax highlighting on
set bs=2                "backspace fix for some systems

" Allow for true colors on Mac
let &t_8f="\<Esc>[38;2;%lu;%lu;%lum"
let &t_8b="\<Esc>[48;2;%lu;%lu;%lum"
set termguicolors

" Allow for italics on Mac
let &t_ZH="\e[3m"
let &t_ZR="\e[23m"

" Vundle Plugins and Settings
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
Plugin 'trusktr/seti.vim'
Plugin 'crusoexia/vim-dracula'
Plugin 'reedes/vim-thematic'
Plugin 'reedes/vim-pencil'
Plugin 'tyrannicaltoucan/vim-quantum'
Plugin 'soli/prolog-vim'
Plugin 'junegunn/vim-journal'
Plugin 'tpope/vim-surround'
Plugin 'scrooloose/syntastic'
Plugin 'altercation/vim-colors-solarized'
Plugin 'ajh17/spacegray.vim'
Plugin 'gsiano/vmux-clipboard'
Plugin 'w0rp/ale'
Plugin 'lervag/vimtex'
Plugin 'arcticicestudio/nord-vim'
Plugin 'lifepillar/vim-solarized8'
Plugin 'rakr/vim-one'
Plugin 'haishanh/night-owl.vim'
call vundle#end()            " required
filetype plugin indent on    " required

" Settings for vim-tex
let g:tex_flavor = 'latex'

" Settings for Airline Statusbar
let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#tabline#left_sep = ' '
let g:airline#extensions#tabline#left_alt_sep = '|'
let g:airline_powerline_fonts = 1
let g:airline_section_x = '%{PencilMode()}'

" Settings for Ale Linter
let g:ale_completion_enabled = 1

" Enable for Night Owl
"let $NVIM_TUI_ENABLE_TRUE_COLOR=1  " enable for nvim
"syntax enable
"colorscheme night-owl
"let g:lightline = { 'colorscheme': 'nightowl' }

" Enable for Nord Theme
let g:airline_theme = 'nord'
let g:nord_italic = 1
let g:nord_italic_comments = 1
let g:nord_cursor_line_number_background = 1
let g:nord_underline = 1
let g:nord_uniform_status_lines = 1
let g:nord_uniform_diff_background = 1
let g:nord_bold = 0
let g:nord_bold_vertical_split_line = 1
let g:lightline = { 'colorscheme' : 'nord' }
"let g:nord_comment_brightness = 15
colorscheme nord

" Enable for Solarized Theme
"set background=dark
"let g:airline_theme='solarized_flood'
"let g:solarized_termcolors=256
"let g:solarized_termtrans=1
"let g:solarized_bold=1
"let g:solarized_italic=1
"let g:solarized_underline=1
"let g:solarized_contrast='normal'
"let g:solarized_visibility='normal'
"colorscheme solarized8

" Enable for vim One
"let g:airline_theme='one'
"let g:one_allow_italics = 1 " I love italic for comments
"let g:one_allow_underline = 1
"colorscheme one

" Enable for Gruvbox Theme
"colorscheme gruvbox
"let g:airline_theme = 'gruvbox'
"let g:gruvbox_termcolors = '256'
"let g:gruvbox_contrast_dark = 'hard'
"let g:gruvbox_italic = 1
"let g:gruvbox_italicize_comments = 1

" Enable for Hybrid Theme
"colorscheme hybrid
"let g:airline_theme = 'tomorrow'

" Enable for Quantum Theme
"colorscheme quantum
"let g:airline_theme = 'quantum'
"let g:quantum_black = 1
"let g:quantum_italics = 1

" Enable for Spacegray Theme
"colorscheme spacegray
"let g:spacegray_use_italics = 1
"let g:spacegray_low_contrast = 1
"let g:spacegray_underline_search = 1
"let g:airline_theme = 'base16_spacemacs'

" Enable for Dracula Theme
"let g:airline_theme = 'dracula'
"let g:dracula_italic = 1
"colorscheme dracula

" GUI Specific Settings
if has("gui_running")
    set guifont=Hack\ Regular:h15
    set guioptions-=r
    set guioptions-=m
    set guioptions-=T
    "set transparency=5
endif

" TMUX Settings
" the following allows the cursor to change in tmux mode
if exists('$TMUX')
    let &t_SI = "\<Esc>Ptmux;\<Esc>\<Esc>]50;CursorShape=1\x7\<Esc>\\"
    let &t_EI = "\<Esc>Ptmux;\<Esc>\<Esc>]50;CursorShape=0\x7\<Esc>\\"
else
    let &t_SI = "\<Esc>]50;CursorShape=1\x7"
    let &t_EI = "\<Esc>]50;CursorShape=0\x7"
endif

"Credit joshdick
"Use 24-bit (true-color) mode in Vim/Neovim when outside tmux.
"If you're using tmux version 2.2 or later, you can remove the outermost $TMUX check and use tmux's 24-bit color support
"(see < http://sunaku.github.io/tmux-24bit-color.html#usage > for more information.)
if (empty($TMUX))
  if (has("nvim"))
  "For Neovim 0.1.3 and 0.1.4 < https://github.com/neovim/neovim/pull/2198 >
  let $NVIM_TUI_ENABLE_TRUE_COLOR=1
  endif
  "For Neovim > 0.1.5 and Vim > patch 7.4.1799 < https://github.com/vim/vim/commit/61be73bb0f965a895bfb064ea3e55476ac175162 >
  "Based on Vim patch 7.4.1770 (`guicolors` option) < https://github.com/vim/vim/commit/8a633e3427b47286869aa4b96f2bfc1fe65b25cd >
  " < https://github.com/neovim/neovim/wiki/Following-HEAD#20160511 >
  if (has("termguicolors"))
    set termguicolors
  endif
endif

" Basic Color Schemes
"colorscheme elflord
"colorscheme wombat
"colorscheme xoria256
"colorscheme inkpot
"colorscheme gardener
"colorscheme simple-dark
"colorscheme Tomorrow-Night-Eighties
"colorscheme Tomorrow-Night
"colorscheme ironman
"colorscheme coffee
"colorscheme matrix
"colorscheme seti
