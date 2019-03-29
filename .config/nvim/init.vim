" vim:fileencoding=utf-8:foldmethod=marker

scriptencoding utf-8

" Use <Space> as my leader
let mapleader=' '

" Simple option settings {{{
set nobackup       " no backup files
set nowritebackup  " only in case you don't want a backup file while editing
set noswapfile     " no swap files

" Tab key inserts 2 spaces
set tabstop=8 softtabstop=0 expandtab shiftwidth=2 smartindent

" Hide line numbers
set nonu

" `word` finds `word`, `Word`, and `WORD`. `WORD` only finds `WORD`.
set ignorecase smartcase

set splitbelow
set splitright

" Highlight the cursor's line
set cursorline
highlight CursorLine cterm=undercurl

" Use tree view in netrw directory browser
let g:netrw_liststyle = 3
" No banner in netrw
let g:netrw_banner = 0
" }}}

" Custom autocmds {{{
" Make long lines more apparent
let &colorcolumn=join(range(81,999),",")
autocmd BufNewFile,BufRead *.tsx,*.ts let &l:colorcolumn=join(range(101,999),",")

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

" Keep splits equal when resizing vim
autocmd VimResized * wincmd =
" }}}

" Custom mappings {{{
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

" Ggrep the current word with with Leader-g
nnoremap <Leader>g :Ggrep "\<<cword>\>"<CR><CR>

nnoremap <Leader>o :TSOrganize<CR>
" }}}

" Install vim-plug if it's missing {{{
if empty(glob('~/.local/share/nvim/site/autoload/plug.vim'))
  silent !curl -fLo ~/.local/share/nvim/site/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif
" }}}

" Install plugins {{{
call plug#begin('~/.local/share/nvim/plugged')

" Fuzzy finder
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }

" Many languages (including Crystal and JSX)
Plug 'sheerun/vim-polyglot'

" Statusline
Plug 'vim-airline/vim-airline'

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

" For Typescript support
Plug 'HerringtonDarkholme/yats.vim'
Plug 'mhartington/nvim-typescript', {'do': './install.sh'}
" For async completion
Plug 'Shougo/deoplete.nvim'
" For Denite features
" Plug 'Shougo/denite.nvim'

" Linting
Plug 'neomake/neomake'

" post install (yarn install | npm install) then load plugin only for editing supported files
Plug 'prettier/vim-prettier', { 'do': 'yarn install' }

" Format Haskell on save
Plug 'alx741/vim-hindent'

" Initialize plugin system
call plug#end()
" }}}

" Configure deoplete {{{
" Enable deoplete at startup
let g:deoplete#enable_at_startup = 1
" }}}

" Configure neomake {{{
" Lint on writes
call neomake#configure#automake('w')
" }}}

" Configure prettier {{{
" Autoformat with Prettier on save
let g:prettier#autoformat = 0
autocmd BufWritePre *.js,*.jsx,*.mjs,*.ts,*.tsx,*.css,*.less,*.scss,*.json,*.graphql,*.md,*.vue PrettierAsync
" }}}

" Configure airline {{{
" Powerline-style statusline
let g:airline_powerline_fonts = 1

" Slim down the statusline
let g:airline_section_b=''
let g:airline_section_y=''
let g:airline_skip_empty_sections=1
" }}}

" Configure fzf {{{
" Open FZF file-finder with ctrl-p
nnoremap <C-p> :FZF <CR>

" Use ag with FZF, showing hidden files but ignoring .git/
let $FZF_DEFAULT_COMMAND = 'ag --hidden --ignore .git -l -g ""'
" }}}

" Configure vim-gitgutter {{{
" Update the GitGutter more frequently
set updatetime=100
" }}}

" Configure polyglot {{{
let g:polyglot_disabled = ['typescript', 'typescript.jsx']
" }}}
