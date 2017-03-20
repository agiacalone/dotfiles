set number              " Add line numbers on the left
set bs=2                " Backspace fix for some systems
set shortmess+=I        " Disable the splash screen
set linespace=2

set nocompatible              " be iMproved, required
filetype off                  " required

" set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()
" alternatively, pass a path where Vundle should install plugins
"call vundle#begin('~/some/path/here')

" let Vundle manage Vundle, required
Plugin 'VundleVim/Vundle.vim'
Plugin 'vim-airline/vim-airline'
Plugin 'vim-airline/vim-airline-themes'
Plugin 'tpope/vim-pathogen'
Plugin 'lesliev/vim-inform7'
Plugin 'godlygeek/tabular'
Plugin 'plasticboy/vim-markdown'
Plugin 'reedes/vim-pencil'
Plugin 'flazz/vim-colorschemes'
Plugin 'beloglazov/vim-online-thesaurus'


" All of your Plugins must be added before the following line
call vundle#end()            " required
filetype plugin indent on    " required

" Set fonts for gVIM
if has("gui_running")
    if has("gui_gtk2")
        set guifont=Inconsolata\ 12
    elseif has("gui_macvim")
        "set guifont=Source\ Code\ \Pro\ for\ Powerline:h14
        "set guifont=Droid\ Sans\ Mono\ Dotted\ for\ Powerline:h14
        set guifont=Monaco\ for\ Powerline:h14
        set antialias
        set guioptions-=r
        "set columns=80 lines=48 
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
let g:airline_theme='dark'

" Disable folding for markdown
let g:vim_markdown_folding_disabled = 1

" Add support for Pencil
augroup pencil
  autocmd!
  autocmd FileType markdown,mkd call pencil#init()
  autocmd FileType text         call pencil#init()
  let g:airline_section_x = '%{PencilMode()}'
augroup END


" Colorschemes section
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
colorscheme basic-dark

"For solarized colors
"let g:solarized_termcolors=256
"colorscheme solarized
"colorscheme miko
