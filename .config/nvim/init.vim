
scriptencoding utf-8

set runtimepath^=~/.vim runtimepath+=~/.vim/after
let &packpath = &runtimepath
" source ~/.vimrc

set nobackup       " no backup files
set nowritebackup  " only in case you don't want a backup file while editing
set noswapfile     " no swap files

" Tab key inserts 2 spaces
set tabstop=8 softtabstop=0 expandtab shiftwidth=2 smarttab smartindent autoindent

" Show line numbers
set nu

" Color the first 80 columns to make long lines more apparent
let index = 1
let &colorcolumn = index
while index < 80
  let index+=1
  let &colorcolumn = &colorcolumn.','.index
endwhile

" Remove trailing whitespace on save
fun! <SID>StripTrailingWhitespaces()
    let l = line(".")
    let c = col(".")
    %s/\s\+$//e
    %s/\($\n\s*\)\+\%$//e
    call cursor(l, c)
endfun
autocmd BufWritePre * :call <SID>StripTrailingWhitespaces()

" Per default, netrw leaves unmodified buffers open. This autocommand
" deletes netrw's buffer once it's hidden (using ':q', for example)
autocmd FileType netrw setl bufhidden=delete


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
if empty(glob('~/.local/share/nvim/site/autoload/plug.vim'))
  silent !curl -fLo ~/.local/share/nvim/site/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

call plug#begin('~/.local/share/nvim/plugged')

" Fuzzy finder
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }

" Many languages (including Crystal and JSX)
Plug 'sheerun/vim-polyglot'

" Statusline
Plug 'vim-airline/vim-airline'

" See https://draculatheme.com/vim/
Plug 'dracula/vim', { 'as': 'dracula' }

" tpope is the man
Plug 'tpope/vim-commentary'
Plug 'tpope/vim-surround'
Plug 'tpope/vim-vinegar'
Plug 'tpope/vim-endwise'
Plug 'tpope/vim-rhubarb'
Plug 'tpope/vim-fugitive'

" Show git diff marks
Plug 'airblade/vim-gitgutter'

" Show number of search matches
Plug 'google/vim-searchindex'

Plug 'junegunn/goyo.vim'

" Get synonyms for writing
Plug 'ron89/thesaurus_query.vim'

" Initialize plugin system
call plug#end()

color dracula

" Apply custom highlights
fun! s:Highlight()
  " Use the terminal background color
  highlight Normal ctermbg=None
  highlight NonText ctermbg=None
  highlight ColorColumn ctermbg=Black
  highlight CursorLine ctermbg=235
endfun

call s:Highlight()

" Reapply custom highlights when the color scheme is reloaded
augroup Highlight
  autocmd! ColorScheme * call s:Highlight()
augroup end

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

" Keep splits equal when resizing vim
autocmd VimResized * wincmd =

" Update the GitGutter more frequently
set updatetime=100

" Use ag with FZF, showing hidden files but ignoring .git/
let $FZF_DEFAULT_COMMAND = 'ag --hidden --ignore .git -l -g ""'
