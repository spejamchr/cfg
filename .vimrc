set nocompatible   " be iMproved
set nobackup       " no backup files
set nowritebackup  " only in case you don't want a backup file while editing
set noswapfile     " no swap files
set hlsearch       " highlight search terms
set incsearch      " highlight search as you search

syntax enable

" Tab key inserts 2 spaces
set tabstop=8 softtabstop=0 expandtab shiftwidth=2 smarttab smartindent autoindent

" Hide line numbers
set nonu

" `word` finds `word`, `Word`, and `WORD`. `WORD` only finds `WORD`.
set ignorecase smartcase

" Color the 81'st column, to show lines that are too long
set colorcolumn=81

" Auto-indent
filetype indent plugin on

" Remove trailing whitespace
fun! <SID>StripTrailingWhitespaces()
    let l = line(".")
    let c = col(".")
    %s/\s\+$//e
    call cursor(l, c)
endfun
" autocmd BufWritePre * :call <SID>StripTrailingWhitespaces()

" Per default, netrw leaves unmodified buffers open. This autocommand
" deletes netrw's buffer once it's hidden (using ':q', for example)
autocmd FileType netrw setl bufhidden=delete

" Always show the statusline
" set laststatus=2

set splitbelow
set splitright

inoremap <C-h> <C-\><C-N><C-w>h
inoremap <C-j> <C-\><C-N><C-w>j
inoremap <C-k> <C-\><C-N><C-w>k
inoremap <C-l> <C-\><C-N><C-w>l
nnoremap <C-J> <C-W><C-J>
nnoremap <C-K> <C-W><C-K>
nnoremap <C-L> <C-W><C-L>
nnoremap <C-H> <C-W><C-H>

" Highlight the cursor's line
set cursorline

" Use tree view in netrw directory browser
let g:netrw_liststyle = 3
" No banner in netrw
let g:netrw_banner = 0

" Show invisible characters
set listchars=tab:»\ ,eol:¬,trail:·
set list

" Highlight trailing spaces
au WinEnter * match ColorColumn /\M\s\+$/
match ColorColumn /\M\s\+$/
