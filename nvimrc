set nocompatible               " be improved, required
filetype off                   " required
" set the runtime path to include Vundle and initialize
set rtp+=~/.config/nvim/bundle/Vundle.vim
call vundle#begin()            " required

" ===================
" my plugins here
" ===================

" let Vundle manage Vundle, required
Plugin 'VundleVim/Vundle.vim'

"vim-fugitive
Plugin 'tpope/vim-fugitive'

Plugin 'w0rp/ale'
"let b:ale_fixers = ['prettier', 'eslint']
"show bar whenever ale is watching (also removed bounce effect when typing)
let g:ale_sign_column_always = 1
"show number of errors on the right side of the airline statusbar
let g:airline#extensions#ale#enabled = 1 

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
    let g:airline_left_sep = "\uE0C6"
    let g:airline_right_sep = "\uE0C7"
endif

"SML
"Plugin 'jez/vim-better-sml'

let g:ale_sign_column_always = 1
"show number of errors on the right side of the airline statusbar
let g:airline#extensions#ale#enabled = 1 

"python auto-indent
Plugin 'vim-scripts/indentpython.vim'

"deoplete
Plugin 'Shougo/deoplete.nvim'
Plugin 'Shougo/neosnippet' 
Plugin 'zchee/deoplete-jedi' 
Plugin 'Shougo/neosnippet-snippets'  
" Use deoplete.
let g:deoplete#enable_at_startup = 0
set completeopt-=preview


au BufRead,BufNewFile *.sml  :exec deoplete#enable()         
au BufRead,BufNewFile *.py   :exec deoplete#enable()
au BufRead,BufNewFile *.c    :exec deoplete#enable()         
au BufRead,BufNewFile *.h    :exec deoplete#enable()         
au BufRead,BufNewFile *.sh   :exec deoplete#enable()         
au BufRead,BufNewFile *.bat  :exec deoplete#enable()
au BufRead,BufNewFile *.java  :exec deoplete#enable()

let g:neosnippet#enable_completed_snippet = 1  

"CTRL + K to complete
imap <C-k>     <Plug>(neosnippet_expand_or_jump)
smap <C-k>     <Plug>(neosnippet_expand_or_jump)
xmap <C-k>     <Plug>(neosnippet_expand_target)

nnoremap <silent> <F5> :exec deoplete#toggle()<CR>

" All of your Plugins must be added before the following line
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

call vundle#end()               " required
filetype plugin indent on       " required


set whichwrap+=h,l,[,]
set mouse=a
set tabstop=4
set shiftwidth=4
set expandtab

"tabline
noremap <F2> :bprevious<CR>
noremap <F3> :bnext<CR>

syntax on

filetype indent on
set lazyredraw

"proverif
 au BufRead,BufNewFile *.pv setfiletype proverif

"disable background
hi Normal ctermbg=none

"colorscheme stuff
"
"colorscheme (uncomment on terminals without transparent background)
"colorscheme default

set background=dark

"fix for powerline not showing
set encoding=utf-8

"Remove the need to save when chaning buffers
set hidden

"open up new split options:
set splitbelow
set splitright

"change windows via SHIFT-TAB
noremap <S-Tab> <C-w><C-w>
tnoremap <S-Tab> <C-w><C-w>
inoremap <S-Tab> <C-w><C-w>

:imap <C-w> <C-o><C-w>

"Save a few seconds when typing ":Wq" instead of ":wq"
":command WQ wq
":command Wq wq
:command W w
":command Q q
"qa=quit all buffers wqa=save and quit all buffers! 
:command WQ wq
:command Wq wq
:command WQA wqa
:command Wqa wqa
:command WQa wqa
:command Q q
:command Qa qa
:command QA qa
"Y -> y
:command Y y


"copied from https://github.com/alienth/dotfiles/blob/master/.vimrc
if exists('+clipboard')
  set clipboard=unnamedplus  " Yanks go to the ctrl-c '+' clipboard register
endif
autocmd VimLeave * call system("xsel -ib", getreg('+'))

set novisualbell  " No blinking the screen upon bells.
set noerrorbells  " No noise.

"enable line numbers by default
set nu

"F4 | toggle line numbers
noremap <F4> :set invnumber<CR> 
:set numberwidth=3
:highlight LineNr term=bold cterm=NONE ctermfg=DarkGrey ctermbg=NONE gui=NONE guifg=DarkGrey guibg=NONE

"start REPL on SML open
"au BufReadPost,BufNewFile *.sml :SMLReplStart


"F9 | save (in regular files)
noremap <F9> :w<CR>

"SML start
function SMLStart()
    try
        :SMLReplStart
        :echo 'SMLRepl started!'
    catch /^Vim\%((\a\+)\)\=:EXXX/
        :echo 'SMLRepl already running!'
        if (bufwinnr("SMLNJ")<0)
            :vsp SMLNJ
            :echo 'SMLRepl opened!'
        else
            :echo 'SMLRepl Window already open!'
        endif
    endtry
endfunction

"F8 | start SML (only in .sml files)
au BufRead,BufNewFile *.sml noremap <F8> :exec SMLStart()<CR>         

"SML Clear And Build
function SMLCAB()
    :w
    :SMLReplClear
    :SMLReplBuild
    :$
endfunction
"F9 | save and build SML Project (only in .sml files)
:au BufRead,BufNewFile *.sml noremap <F9> :exec SMLCAB()<CR>

"SML command shortcuts
:command SS SMLReplStart
:command SC SMLReplClear
:command SB SMLReplBuild
:command Sclose wqa


"If smlnj is in fullscreen close buffer
function TC()
    if ((winnr('$')==1) && (&filetype =='smlnj'))    
        :q
    endif
endfunction

"switch to insert mode when in buffer
":au BufEnter * if &buftype == 'terminal' | :startinsert | endif
:au BufEnter * if &buftype == 'terminal' | :exec TC() | :startinsert | endif


noremap <silent> <C-l> :nohl<CR><C-l>

:tnoremap <Esc> <C-\><C-n>

nmap <silent> <A-Up> :wincmd k<CR>
nmap <silent> <A-Down> :wincmd j<CR>
nmap <silent> <A-Left> :wincmd h<CR>
nmap <silent> <A-Right> :wincmd l<CR>


noremap <F1> :echo 'Annoyance avoided!'<CR>

"prevent automatic linebreaks
:set wrap

"CTRL+back => delete word
:imap <C-BS> <C-W>
:set backspace=indent,eol,start


"increase buffer size
:set viminfo='200,<200,s40,h
