set nocompatible              " be iMproved, required
filetype off                  " required

" set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()
" alternatively, pass a path where Vundle should install plugins
"call vundle#begin('~/some/path/here')

" let Vundle manage Vundle, required
Plugin 'VundleVim/Vundle.vim'

"vim-fugitive
Plugin 'tpope/vim-fugitive'

"pyton auto-indent
"Plugin 'vim-scripts/indentpython.vim'

"airline
Plugin 'vim-airline/vim-airline'
Plugin 'vim-airline/vim-airline-themes'
let g:airline#extensions#tabline#formatter = 'default'
let g:airline#extensions#tabline#enabled = 1

let myterm = $TERM
if myterm=~'linux'
    "running on tty; Disable powerline symbols
    let g:airline_powerline_fonts = 0
    let g:airline_left_sep = ''
    let g:airline_right_sep = ''
else 
    let g:airline_powerline_fonts = 1
"   If nerd fonts are installed, uncomment these lines to replace the default
"   powerline separators with cool new ones
"   Fonts can be found here: 
"   https://github.com/ryanoasis/nerd-fonts/releases/tag/v1.2.0
    "let g:airline_left_sep = "\uE0C6"
    "let g:airline_right_sep = "\uE0C7"
endif

" All of your Plugins must be added before the following line
call vundle#end()            " required
filetype plugin indent on    " required
" To ignore plugin indent changes, instead use:
"filetype plugin on
"
" Brief help
" :PluginList       - lists configured plugins
" :PluginInstall    - installs plugins; append `!` to update or just :PluginUpdate
" :PluginSearch foo - searches for foo; append `!` to refresh local cache
" :PluginClean      - confirms removal of unused plugins; append `!` to auto-approve removal
"
" see :h vundle for more details or wiki for FAQ
" Put your non-Plugin stuff after this line


set whichwrap+=h,l,[,]
set mouse=a
set tabstop=4
set shiftwidth=4
set expandtab

"tabline
nnoremap <F2> :bprevious<CR>
nnoremap <F3> :bnext<CR>

"line numbers
"toggle line numbers
nnoremap <F4> :set invnumber<CR>

"line number color
:highlight LineNr term=bold cterm=NONE ctermfg=DarkGrey ctermbg=NONE gui=NONE guifg=DarkGrey guibg=NONE

"line number width
:set numberwidth=3

"use column for wrapped lines
":set cpoptions+=n


"uncomment for line numbers on start
"set nu 

syntax on

filetype indent on
set lazyredraw

"proverif
 au BufRead,BufNewFile *.pv setfiletype proverif

"colorscheme (uncomment on terminals without transparent background)
"colorscheme darkblue
set background=dark

"disable background
hi Normal ctermbg=none

"fix for powerline not showing
set encoding=utf-8

"Remove the need to save when chaning buffers
set hidden

"open up new split options:
set splitbelow
set splitright

"change windows via SHIFT-TAB
nnoremap <S-Tab> <C-w><C-w>

"Alt+direction split navigation
nmap <silent> <A-Up> :wincmd k<CR>
nmap <silent> <A-Down> :wincmd j<CR>
nmap <silent> <A-Left> :wincmd h<CR>
nmap <silent> <A-Right> :wincmd l<CR>

:imap <C-w> <C-o><C-w>

"Save a few seconds when typing ":Wq" instead of ":wq"
:command WQ wq
:command Wq wq
:command W w
:command Q q
"qa=quit all buffers wqa=save and quit all buffers! 
:command WQA wqa
:command Wqa wqa
:command WQa wqa
:command Qa qa
:command QA qa
"Y -> y
:command Y y


"If nerd fonts are installed, uncomment these lines to replace the default
"powerline separators with cool new ones
"(I usually use them for ROOT, so I know when vim runs as root!)"
"Fonts can be found here: 
"https://github.com/ryanoasis/nerd-fonts/releases/tag/v1.2.0
"let g:airline_left_sep = "\uE0C6"
"let g:airline_right_sep = "\uE0C7"

"copied from https://github.com/alienth/dotfiles/blob/master/.vimrc
if exists('+clipboard')
  set clipboard=unnamedplus  " Yanks go to the ctrl-c '+' clipboard register
endif
autocmd VimLeave * call system("xsel -ib", getreg('+'))

set novisualbell  " No blinking the screen upon bells.
set noerrorbells  " No noise.

nnoremap <silent> <C-l> :nohl<CR><C-l>

"annoyances
noremap <F1> :echo 'Annoyance avoided!'<CR>

"no automatic line break
:set wrap
:set formatoptions-=t
:set wrapmargin=0
:set textwidth=0 
