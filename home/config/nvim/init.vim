" vim:fileencoding=utf-8:foldmethod=marker

scriptencoding utf-8

" Use <Space> as my Leader
let mapleader=' '

" Simple option settings {{{
" If hidden is not set, coc.nvim's TextEdit might fail
set hidden

set nobackup       " no backup files
set nowritebackup  " only in case you don't want a backup file while editing
set noswapfile     " no swap files

" More frequent updates for CursorHold events (GitGutter, coc.nvim)
set updatetime=100

" Tab key inserts 2 spaces
set tabstop=4 softtabstop=0 expandtab shiftwidth=2 smartindent

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

" Show incremental commands
set inccommand=split
" }}}

" Custom autocmds {{{
" Make long lines more apparent
let &colorcolumn=join(range(81,999),",")
autocmd BufNewFile,BufRead *.jsx,*.js,*.tsx,*.ts let &l:colorcolumn=join(range(101,999),",")

" Spellcheck markdown and text files, and wrap at 80th column
autocmd BufNewFile,BufRead *.md,*.txt setlocal spell spelllang=en_us textwidth=80

" Remove trailing whitespace on save
fun! <SID>StripTrailingWhitespaces()
    let l = line(".")
    let c = col(".")
    %s/\s\+$//e
    %s/\($\n\s*\)\+\%$//e
    call cursor(l, c)
endfun
" Don't remove whitespace in diff files, it's important there.
autocmd BufWritePre * if &ft!~?'diff'|:call <SID>StripTrailingWhitespaces()|endif

" Show invisible characters in diff files
set listchars=tab:»\ ,eol:¬,trail:·
autocmd FileType diff setlocal list

" Per default, netrw leaves unmodified buffers open. This autocommand
" deletes netrw's buffer once it's hidden (using ':q', for example)
autocmd FileType netrw setlocal bufhidden=delete

" Keep splits equal when resizing vim
autocmd VimResized * wincmd =
" }}}

" Custom mappings {{{
" Use `CTRL+{h,j,k,l}` to navigate windows from normal and terminal modes:
tnoremap <C-h> <C-\><C-N><C-w>h
tnoremap <C-j> <C-\><C-N><C-w>j
tnoremap <C-k> <C-\><C-N><C-w>k
tnoremap <C-l> <C-\><C-N><C-w>l
nnoremap <C-h> <C-w>h
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-l> <C-w>l

nnoremap <Leader>d :Gdiff<CR>
nnoremap <Leader>w :w<CR>

" Correct spelling mistake under the cursor
nnoremap <Leader>s [s1z=<C-o>
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
Plug 'junegunn/fzf.vim'

" Many languages (including Crystal and JSX)
Plug 'sheerun/vim-polyglot'

" Statusline
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'

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

" Intellisense engine. Language Server Protocol support as full as VSCode
Plug 'neoclide/coc.nvim', { 'branch': 'release' }

" Snippets
Plug 'SirVer/ultisnips'
Plug 'honza/vim-snippets'

" coc.nvim plugins
Plug 'neoclide/coc-json', { 'do': 'yarn install --frozen-lockfile' }
Plug 'neoclide/coc-tsserver', { 'do': 'yarn install --frozen-lockfile' }
Plug 'neoclide/coc-css', { 'do': 'yarn install --frozen-lockfile' }
Plug 'neoclide/coc-rls', { 'do': 'yarn install --frozen-lockfile' }
Plug 'neoclide/coc-solargraph', { 'do': 'yarn install --frozen-lockfile' }

" post install (yarn install | npm install) then load plugin only for editing supported files
Plug 'prettier/vim-prettier', { 'do': 'yarn install' }

" Format Haskell on save
Plug 'alx741/vim-hindent'

" Markdown
Plug 'iamcco/markdown-preview.nvim', { 'do': 'cd app & yarn install'  }

Plug 'chriskempson/base16-vim'

" Preview colours in source code while editing
Plug 'chrisbra/Colorizer'

" Initialize plugin system
call plug#end()
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
" Fuzzy find files in the working directory
nnoremap <Leader>f :Files<CR>

" Search for the word under the cursor
nnoremap <Leader>g :Rg <C-r><C-w><CR>

" Fuzzy find text in the working directory
nnoremap <Leader>G :Rg<CR>

" Fuzzy find lines in the current file
nnoremap <Leader>/ :BLines<CR>

" Fuzzy find Vim commands
nnoremap <Leader>c :Commands<CR>

" Fuzzy find buffers
nnoremap <Leader>b :Buffers<CR>

" Fuzzy find history
nnoremap <Leader>h :History<CR>

" Use rg with FZF, showing hidden files but ignoring .git/
let $FZF_DEFAULT_COMMAND = 'rg --files --hidden --glob "!.git/*"'

" Use bat to preview files found with fzf
let g:bat_alias='bat --style=changes,numbers --color always --theme=base16'
let g:bat_context=5
let g:preview='if test -f {}; then if file -i {}|grep -q binary; then file -b {}; else ' . g:bat_alias . ' {}; fi; else; file=$(echo {} | sed "s/:.*$//g"); if [[ -f $file ]]; then line=$(echo {} | sed "s/^[^:]*://g" | sed "s/:.*$//g"); ' . g:bat_alias . ' -H $line -r $([[ $((line - ' . g:bat_context . ')) -gt 0 ]] && echo $((line - ' . g:bat_context . ')) || echo 1):$(($line + ' . g:bat_context . ')) $file; else; file=$(echo {} | sed "s/\[[^ ]*\]//g" | tr -d "[:blank:]"); if [[ -f $file ]]; then ' . g:bat_alias . ' $file; else if [[ -d $file ]]; then echo "$file:\n\n$(ls -1AFG $file)"; fi; fi; fi; fi'

let $FZF_DEFAULT_OPTS=" --color=16,border:8,bg:0 --border --layout=reverse --preview '".preview."'"

" FZF opens in a floating window
let g:fzf_layout = { 'window': 'call FloatingFZF()' }

function! FloatingFZF()
  let buf = nvim_create_buf(v:false, v:true)
  call setbufvar(buf, '&signcolumn', 'no')

  let height = float2nr(30)
  let width = float2nr(&columns * 3 / 4)
  let horizontal = float2nr((&columns - width) / 2)
  let vertical = float2nr((&lines - height) / 2)

  let opts = {
        \ 'relative': 'editor',
        \ 'row': vertical,
        \ 'col': horizontal,
        \ 'width': width,
        \ 'height': height,
        \ }

  call nvim_open_win(buf, v:true, opts)
endfunction
" }}}

" Configure markdown-preview.nvim {{{
" Do not auto-start when opening markdown files
let g:mkdp_auto_start = 0

" Do not auto-close when closing markdown files
let g:mkdp_auto_close = 0
" }}}

" Configure coc.nvim {{{
inoremap <silent><expr> <C-space> coc#refresh()

" Use `[c` and `]c` to navigate diagnostics
nmap <silent> [e <Plug>(coc-diagnostic-prev)
nmap <silent> ]e <Plug>(coc-diagnostic-next)

" Remap keys for gotos
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)

" Remap for rename current word
nmap <Leader>rn <Plug>(coc-rename)
nmap <Leader>o :call CocActionAsync('runCommand', 'tsserver.organizeImports')<CR>

augroup coc-nvim
  autocmd!
  " Setup formatexpr specified filetype(s).
  autocmd FileType typescript,json setlocal formatexpr=CocAction('formatSelected')
  " Update signature help on jump placeholder
  autocmd User CocJumpPlaceholder call CocActionAsync('showSignatureHelp')
augroup end
" Fix autofix problem of current line
nmap <Leader>qf  <Plug>(coc-fix-current)
" }}}

" Configure base16-vim {{{
if filereadable(expand("~/.vimrc_background"))
  let base16colorspace=256
  set termguicolors
  source ~/.vimrc_background
endif
" }}}

" Configure ron89/thesaurus_query.vim {{{
let g:tq_openoffice_en_file="~/Documents/OpenOfficeThesaurus/th_en_US_new"
" }}}

" Configure SirVer/ultisnips {{{
let g:UltiSnipsExpandTrigger='<c-j>'

" shortcut to go to next position
let g:UltiSnipsJumpForwardTrigger='<c-j>'

" shortcut to go to previous position
let g:UltiSnipsJumpBackwardTrigger='<c-k>'

" }}}
