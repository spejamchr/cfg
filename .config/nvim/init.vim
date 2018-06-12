
scriptencoding utf-8

set runtimepath^=~/.vim runtimepath+=~/.vim/after
let &packpath = &runtimepath
source ~/.vimrc

set nobackup       " no backup files
set nowritebackup  " only in case you don't want a backup file while editing
set noswapfile     " no swap files

" Tab key inserts 2 spaces
set tabstop=8 softtabstop=0 expandtab shiftwidth=2 smarttab smartindent autoindent

"colorscheme seti
color dracula

" Show line numbers
set nu

" Color the 81'st column, to show lines that are too long
set colorcolumn=81

" Remove trailing whitespace on save
fun! <SID>StripTrailingWhitespaces()
    let l = line(".")
    let c = col(".")
    %s/\s\+$//e
    call cursor(l, c)
endfun
autocmd BufWritePre * :call <SID>StripTrailingWhitespaces()

" Always show the statusline
"set laststatus=2

"set statusline=%f\ %{fugitive#statusline()}

set splitbelow
set splitright

" Use `CTRL+{h,j,k,l}` to navigate windows from any mode:
tnoremap <C-h> <C-\><C-N><C-w>h
tnoremap <C-j> <C-\><C-N><C-w>j
tnoremap <C-k> <C-\><C-N><C-w>k
tnoremap <C-l> <C-\><C-N><C-w>l
inoremap <C-h> <C-\><C-N><C-w>h
inoremap <C-j> <C-\><C-N><C-w>j
inoremap <C-k> <C-\><C-N><C-w>k
inoremap <C-l> <C-\><C-N><C-w>l
nnoremap <C-h> <C-w>h
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-l> <C-w>l

" Highlight the cursor's line
set cursorline

" Use tree view in netrw directory browser
let g:netrw_liststyle = 3
" No banner in netrw
let g:netrw_banner = 0

" Use vim-plug
call plug#begin('~/.local/share/nvim/plugged')

" Fuzzy finder
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }

" Crystal support
Plug 'rhysd/vim-crystal'

" Statusline
Plug 'vim-airline/vim-airline'

" See https://draculatheme.com/vim/
Plug 'dracula/vim', { 'as': 'dracula' }

Plug 'tpope/vim-commentary'
Plug 'tpope/vim-surround'
Plug 'tpope/vim-vinegar'
Plug 'tpope/vim-endwise'

" Initialize plugin system
call plug#end()

" replace all old-style rocket syntaxes with newer versions
" :example => thing  ->  example: thing
"command RTN %s/:\(\w\+\) =>/\1:/g

" Show invisible characters
set listchars=tab:»\ ,eol:¬,trail:·
set list

" Highlight trailing spaces
au WinEnter * match ColorColumn /\M\s\+$/
match ColorColumn /\M\s\+$/

" Powerline-style statusline
let g:airline_powerline_fonts = 1

" Open FZF file-finder with ctrl-p
nnoremap <C-p> :FZF <CR>
