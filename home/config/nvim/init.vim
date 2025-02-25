" vim:fileencoding=utf-8:foldmethod=marker

scriptencoding utf-8

" Use <Space> as my Leader
let mapleader=' '

" Simple option settings {{{
set hidden

" fish is great for interactive shells, but for editing use zsh
set shell=/bin/zsh

" Always show the signcolumn to prevent the text from bouncing
set signcolumn=yes

set nobackup       " no backup files
set nowritebackup  " only in case you don't want a backup file while editing
set noswapfile     " no swap files

" More frequent updates for CursorHold events (GitGutter)
set updatetime=100

" Tab key inserts 2 spaces normally
set tabstop=2 softtabstop=0 expandtab shiftwidth=2 smartindent
augroup custom_indentation
  autocmd!

  " for c# files, tab is 4 spaces
  autocmd Filetype cs setlocal ts=4 sw=4
augroup END

" Hide line numbers
set nonu

" `word` finds `word`. `Word` finds `Word`. `WORD` finds `WORD`.
set noignorecase smartcase

set splitbelow
set splitright

" disable the mouse
set mouse=

" Highlight the cursor's line
" set cursorline
highlight CursorLine cterm=undercurl

" Use tree view in netrw directory browser
let g:netrw_liststyle = 3
" No banner in netrw
let g:netrw_banner = 0

" Show incremental commands
set inccommand=split

" Use one space when joining sentences with J or gqip instead of two spaces
set nojoinspaces

" Keep undo history across sessions by storing it in a file
if has('persistent_undo')
  let vimDir = '$XDG_CONFIG_HOME/nvim'
  let myUndoDir = expand(vimDir . '/undodir')

  " Create dirs
  call system('mkdir ' . vimDir)
  call system('mkdir ' . myUndoDir)

  let &undodir = myUndoDir
  set undofile
endif
" }}}

" Custom autocmds {{{
" Make long lines more apparent
let &colorcolumn=join(range(101,999),",")

" Spellcheck markdown and text files, and wrap at 100th column
autocmd BufNewFile,BufRead *.md,*.txt setlocal spell spelllang=en_us textwidth=100

" Remove trailing whitespace on save
fun! <SID>StripTrailingWhitespaces()
    let l = line(".")
    let c = col(".")
    let s = @/
    %s/\s\+$//e
    %s/\($\n\s*\)\+\%$//e
    call cursor(l, c) " Restore the cursor
    let @/ = s " Restore the search
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

" {{{ Custom functions

" Delete all hidden buffers, and show a count of how many were deleted.
" See: https://stackoverflow.com/a/30101152/3821061
function! DeleteHiddenBuffers()
  let tpbl=[]
  let closed = 0
  call map(range(1, tabpagenr('$')), 'extend(tpbl, tabpagebuflist(v:val))')
  for buf in filter(range(1, bufnr('$')), 'bufexists(v:val) && index(tpbl, v:val)==-1')
    if getbufvar(buf, '&mod') == 0
      silent execute 'bwipeout' buf
      let closed += 1
    endif
  endfor
  echo "Closed ".closed." hidden buffers"
endfunction

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

nnoremap <Leader>w :w<CR>

fun! <SID>FixMostRecentSpellingError()
  let l = line(".")
  let c = col(".")
  normal [s1z=
  call cursor(l, c)
endfun

" Correct spelling mistake under the cursor
" nnoremap <Leader>s :call <Sid>FixMostRecentSpellingError()<CR>

" Delete all hidden buffers (clearing up the buffer list)
nnoremap <Leader>d :call DeleteHiddenBuffers()<CR>
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
Plug '/opt/homebrew/opt/fzf'
Plug 'ibhagwan/fzf-lua', {'branch': 'main'} " SJC TODO: Switch to this?

" Use FZF with the LSP
Plug 'gfanto/fzf-lsp.nvim'

" tpope is the man
Plug 'tpope/vim-commentary'
Plug 'tpope/vim-surround'
Plug 'tpope/vim-endwise'
Plug 'tpope/vim-rhubarb'
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-repeat'

" Show git diff marks
Plug 'lewis6991/gitsigns.nvim'

" Even fewer distractions
Plug 'junegunn/goyo.vim'

" Get synonyms for writing
Plug 'ron89/thesaurus_query.vim'

" Mason makes it easy to install LSP servers and stuff (things outside of nvim)
" lspconfig makes it easy to configure nvim's builtin LSP stuff
" mason-lspconfig helps link them
Plug 'williamboman/mason.nvim'
Plug 'williamboman/mason-lspconfig.nvim'
Plug 'neovim/nvim-lspconfig'

"Plug 'folke/lsp-trouble.nvim' " SJC TODO: Do I use this?

Plug 'nvim-lua/plenary.nvim'
Plug 'stevearc/dressing.nvim'

" Autocompletion
Plug 'hrsh7th/cmp-nvim-lsp'
Plug 'hrsh7th/cmp-buffer'
Plug 'hrsh7th/cmp-path'
Plug 'hrsh7th/cmp-cmdline'
Plug 'hrsh7th/nvim-cmp'
Plug 'hrsh7th/cmp-nvim-lsp-signature-help'

" Snippets
Plug 'SirVer/ultisnips'
Plug 'honza/vim-snippets'
Plug 'quangnguyen30192/cmp-nvim-ultisnips'

" Format code
Plug 'sbdchd/neoformat'

" Markdown
Plug 'iamcco/markdown-preview.nvim', { 'do': 'cd app & yarn install'  }

" Themes
Plug 'RRethy/base16-nvim'
Plug 'folke/tokyonight.nvim', { 'branch': 'main' }

" Preview colours in source code while editing
Plug 'chrisbra/Colorizer'

" Replace netrw
Plug 'lambdalisue/fern.vim'
Plug 'lambdalisue/fern-hijack.vim'
Plug 'lambdalisue/fern-git-status.vim'

" Jetpack navigation
Plug 'ggandor/leap.nvim'

Plug 'windwp/nvim-autopairs'

" Treesitter...
Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}
Plug 'JoosepAlviste/nvim-ts-context-commentstring'

" Nicer Typescript support
Plug 'jose-elias-alvarez/typescript.nvim'

" Initialize plugin system
call plug#end()
" }}}

" Configure autocompletions with nvim-cmp {{{
set completeopt=menu,menuone,noselect

lua <<EOF
  -- Setup nvim-cmp.
  local cmp = require'cmp'

  cmp.setup({
    snippet = {
      expand = function(args)
        vim.fn["UltiSnips#Anon"](args.body) -- For `ultisnips` users.
      end,
    },
    window = {
      completion = cmp.config.window.bordered(),
      documentation = cmp.config.window.bordered(),
    },
    mapping = cmp.mapping.preset.insert({
      ['<C-b>'] = cmp.mapping.scroll_docs(-4),
      ['<C-f>'] = cmp.mapping.scroll_docs(4),
      ['<C-Space>'] = cmp.mapping.complete(),
      ['<C-e>'] = cmp.mapping.abort(),
      ['<C-j>'] = cmp.mapping.confirm({ select = true }),
    }),
    sources = cmp.config.sources({
      { name = 'nvim_lsp' },
      { name = 'ultisnips' }, -- For ultisnips users.
      { name = 'nvim_lsp_signature_help' }
    }, {
      { name = 'buffer' },
    })
  })

  -- Set configuration for specific filetype.
  cmp.setup.filetype('gitcommit', {
    sources = cmp.config.sources({
      { name = 'buffer' },
    })
  })

  -- Use buffer source for `/` (if you enabled `native_menu`, this won't work anymore).
  cmp.setup.cmdline('/', {
    mapping = cmp.mapping.preset.cmdline(),
    sources = {
      { name = 'buffer' }
    }
  })

  -- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
  cmp.setup.cmdline(':', {
    mapping = cmp.mapping.preset.cmdline(),
    sources = cmp.config.sources({
      { name = 'path' }
    }, {
      { name = 'cmdline' }
    })
  })

EOF

" }}}

" Configure LSP {{{
lua << EOF
require("mason").setup()
require("mason-lspconfig").setup({
  ensure_installed = {
    'jsonls',
    'omnisharp',
    'rust_analyzer',
    'solargraph',
    'tailwindcss',
    'ts_ls',
  },
})

-- Mappings.
-- See `:help vim.diagnostic.*` for documentation on any of the below functions
local opts = { noremap=true, silent=true }
vim.keymap.set('n', '<Leader>e', vim.diagnostic.open_float, opts)
vim.keymap.set('n', '<Leader>lk', vim.diagnostic.goto_prev, opts)
vim.keymap.set('n', '<Leader>gd', vim.lsp.buf.definition, opts)
vim.keymap.set('n', '<Leader>lj', vim.diagnostic.goto_next, opts)
vim.keymap.set('n', '<Leader>q', vim.diagnostic.setloclist, opts)

-- Use an on_attach function to only map the following keys
-- after the language server attaches to the current buffer
 local on_attach = function(client, bufnr)
   -- Enable completion triggered by <c-x><c-o>
   vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')

   -- Mappings.
   -- See `:help vim.lsp.*` for documentation on any of the below functions
   local bufopts = { noremap=true, silent=true, buffer=bufnr }
   vim.keymap.set('n', 'K', vim.lsp.buf.hover, bufopts)
   vim.keymap.set('n', '<Leader>rn', vim.lsp.buf.rename, bufopts)
   vim.keymap.set('n', '<Leader>qf', vim.lsp.buf.code_action, bufopts)
   vim.keymap.set('n', '<Leader>rf', vim.lsp.buf.format, bufopts)
 end

local capabilities = require('cmp_nvim_lsp').default_capabilities(vim.lsp.protocol.make_client_capabilities())

require("mason-lspconfig").setup_handlers {
  -- The first entry (without a key) will be the default handler
  -- and will be called for each installed server that doesn't have
  -- a dedicated handler.
  function (server_name) -- default handler (optional)
    require("lspconfig")[server_name].setup {
      on_attach = on_attach,
      capabilities = capabilities,
    }
  end,

  -- next, you can provide a dedicated handler for specific servers.
  ["cssls"] = function()
    require('lspconfig').cssls.setup({
      settings = {
        css = {
          lint = {
            unknownAtRules = 'ignore',
          },
        },
      },
    })
  end,

  ["tailwindcss"] = function()
    require("lspconfig").tailwindcss.setup {
      on_attach = on_attach,
      capabilities = capabilities,
      settings = {
        tailwindCSS = {
          experimental = {
            classRegex = {
              -- enable tailwind in haml: https://github.com/paolotiu/tailwind-intellisense-regex-list#haml
              { "class: ?\"([^\"]*)\"", "([a-zA-Z0-9\\-:]+)" },
              { "(\\.[\\w\\-.]+)[\\n\\=\\{\\s]", "([\\w\\-]+)" },
            }
          }
        }
      }
    }
  end,

  ["solargraph"] = function()
    require("lspconfig").solargraph.setup {
      on_attach = on_attach,
      capabilities = capabilities,
      root_dir = require('lspconfig').util.root_pattern("Gemfile", ".git", "."),
      settings = {
        solargraph = {
          autoformat = false,
          formatting = false,
          completion = true,
          diagnostic = true,
          folding = true,
          references = true,
          rename = true,
          symbols = true
        }
      }
    }
  end
}

local _border = "rounded"

vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(
  vim.lsp.handlers.hover, {
    border = _border
  }
)

vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(
  vim.lsp.handlers.signature_help, {
    border = _border
  }
)

vim.diagnostic.config{
  float={border=_border}
}

require('lspconfig.ui.windows').default_options = {
  border = _border
}

local lspconfig = require("lspconfig")

local function organize_imports()
  local bufnr = vim.api.nvim_get_current_buf()
  local params = {
    command = "_typescript.organizeImports",
    arguments = {vim.api.nvim_buf_get_name(bufnr)},
    title = ""
  }
  vim.lsp.buf.execute_command(params)
  -- perform a syncronous request
  -- 500ms timeout depending on the size of file a bigger timeout may be needed
  vim.lsp.buf_request_sync(bufnr, "workspace/executeCommand", params, 500)
end

lspconfig.ts_ls.setup {
  on_attach = on_attach,
  capabilities = capabilities,
  commands = {
    OrganizeImports = {
      organize_imports,
      description = "Organize Imports"
    }
  }
}

EOF

augroup organize_imports
  autocmd!

  autocmd BufWritePre *.js,*.jsx,*.ts,*.tsx silent! undojoin | OrganizeImports
augroup END
" }}}

" Configure code auto-formatting with Neoformat {{{
let g:neoformat_try_node_exe = 1

augroup fmt
  autocmd!

  " Autoformat with Neoformat on save
  autocmd BufWritePre *.js,*.jsx,*.ts,*.tsx,*.rs Neoformat
augroup END

nnoremap <Leader>p :Neoformat<CR>
" }}}

" Configure fzf {{{
lua << EOF
local actions = require "fzf-lua.actions"
require'fzf-lua'.setup {
  actions = {
    files = {
      ["enter"]       = actions.file_edit_or_qf,
      ["ctrl-x"]      = actions.file_split,
      ["ctrl-v"]      = actions.file_vsplit,
      ["ctrl-t"]      = actions.file_tabedit,
    },
  },
}
EOF

" Fuzzy find files in the working directory
nnoremap <Leader>f :FzfLua files<CR>

" Search for the word under the cursor
nnoremap <Leader>sg :FzfLua grep_cword<CR>

" Fuzzy find text in the working directory
nnoremap <Leader>st :FzfLua live_grep<CR>

" Fuzzy find Vim uommands
nnoremap <Leader>sc :FzfLua commands<CR>

" Fuzzy find buffers
nnoremap <Leader>sb :FzfLua buffers<CR>

" Fuzzy find history
nnoremap <Leader>sh :FzfLua oldfiles<CR>

" Configure FZF with LSP
nnoremap gd :Definitions<CR>
nnoremap gr :References<CR>
" }}}

" Configure markdown-preview.nvim {{{
" Do not auto-start when opening markdown files
let g:mkdp_auto_start = 0

" Do not auto-close when closing markdown files
let g:mkdp_auto_close = 0
" }}}

" Configure colorscheme w/base16 {{{
" lua require("base16-nvim").setup({})

let base16colorspace=256
set termguicolors

if filereadable(expand("~/.vimrc_background"))
  source ~/.vimrc_background
endif

" colorscheme tokyonight-night

" Configure highlighting (must be done after initializing the colorscheme) {{{
" Italicize comments
highlight Comment cterm=italic gui=italic
" Italicize and bold markdown stuff
highlight htmlItalic cterm=italic gui=italic
highlight htmlBold cterm=bold gui=bold
" }}}

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

" Configure lambdalisue/fern.vim {{{

" Open Fern in the current dir and highlight the current file
nmap - :Fern %:h -reveal=%:p<CR>

" Show hidden files by default
let g:fern#default_hidden = 1

" Only use my mappings
let g:fern#disable_default_mappings = 1

let g:fern#renderer#default#leaf_symbol = '| '
let g:fern#renderer#default#collapsed_symbol = '+ '
let g:fern#renderer#default#expanded_symbol = '- '

" Perform 'open' on leaf node, 'expand' on collapsed node, and 'collapse' on
" expanded node. From fern's docs.
nmap <silent><expr>
      \ <Plug>(fern-action-open-or-expand-or-collapse)
      \ fern#smart#leaf(
      \   "\<Plug>(fern-action-open)",
      \   "\<Plug>(fern-action-expand)",
      \   "\<Plug>(fern-action-collapse)",
      \ )

" Define my mappings {{{
function! s:init_fern() abort
  "Splits
  nmap <buffer> <C-x> <Plug>(fern-action-open:split)
  nmap <buffer> <C-v> <Plug>(fern-action-open:vsplit)

  " Navigation
  nmap <buffer> - <Plug>(fern-action-leave)
  nmap <buffer> _ <Plug>(fern-action-enter)
  nmap <buffer> r <Plug>(fern-action-reload)
  nmap <buffer> z <Plug>(fern-action-expand)

  nmap <buffer> <Return> <Plug>(fern-action-open-or-expand-or-collapse)

  " CRUD
  nmap <buffer> <Leader>n <Plug>(fern-action-new-path)
  nmap <buffer> <Leader>d <Plug>(fern-action-remove)
  nmap <buffer> <Leader>m <Plug>(fern-action-rename)

  " Copy
  nmap <buffer> <Leader>c <Plug>(fern-action-copy)

  " Marks
  nmap <buffer> <C-n> <Plug>(fern-action-mark:toggle)j
  nmap <buffer> <C-p> <Plug>(fern-action-mark:toggle)k
  nmap <buffer> <C-t> <Plug>(fern-action-mark:toggle)
  nmap <buffer> <C-c> <Plug>(fern-action-mark:clear)
endfunction

augroup fern-custom
  autocmd! *
  autocmd FileType fern call s:init_fern()
augroup END
" }}}

" }}}

" Configure ggandor/leap {{{
lua require('leap').add_default_mappings()
" }}}

" Configure windwp/nvim-autopairs {{{
lua << EOF
require("nvim-autopairs").setup {}
EOF
" }}}

" Configure Treesitter {{{
lua <<EOF
require'nvim-treesitter.configs'.setup {
  auto_install = true,
  highlight = { enable = true },
  incremental_selection = { enable = true },
  textobjects = { enable = true },
  indent = { enable = true },
  context_commentstring = { enable = false },
}
EOF
" }}}

" Configure lewis6991/gitsigns.nvim {{{
" See https://github.com/lewis6991/gitsigns.nvim#keymaps
lua <<EOF
require('gitsigns').setup({
  on_attach = function(bufnr)
    local gs = package.loaded.gitsigns

    local function map(mode, l, r, opts)
      opts = opts or {}
      opts.buffer = bufnr
      vim.keymap.set(mode, l, r, opts)
    end

    -- Stage hunk
    map('n', '<leader>ga', function()
      if vim.wo.diff then return '<leader>ga' end
      vim.schedule(function() gs.stage_hunk() end)
      return '<Ignore>'
    end, {expr=true})

    -- Navigation
    map('n', '<leader>gj', function()
      if vim.wo.diff then return '<leader>gj' end
      vim.schedule(function() gs.next_hunk() end)
      return '<Ignore>'
    end, {expr=true})

    map('n', '<leader>gk', function()
      if vim.wo.diff then return '<leader>gk' end
      vim.schedule(function() gs.prev_hunk() end)
      return '<Ignore>'
    end, {expr=true})
  end
})
EOF
" }}}

" Custom highlight groups for old themes {{{
fun! <SID>HighlightOldGroups()
  " Misc {{{
  hi link @comment Comment
  hi link @error Error
  hi link @none NONE
  hi link @preproc PreProc
  hi link @define Define
  hi link @operator Operator
  " }}}

  " Punctuation {{{
  hi link @punctuation.delimiter Delimiter
  hi link @punctuation.bracket Delimiter
  hi link @punctuation.special Delimiter
  " }}}

  " Literals {{{
  hi link @string String
  hi link @string.regex String
  hi link @string.escape SpecialChar
  hi link @string.special SpecialChar

  hi link @character Character
  hi link @character.special SpecialChar

  hi link @boolean Boolean
  hi link @number Number
  hi link @float Float
  " }}}

  " Functions {{{
  hi link @function Function
  hi link @function.call Function
  hi link @function.builtin Special
  hi link @function.macro Macro

  hi link @method Function
  hi link @method.call Function

  hi link @constructor Special
  hi link @parameter Identifier
  " }}}

  " Keywords {{{
  hi link @keyword Keyword
  hi link @keyword.function Keyword
  hi link @keyword.operator Keyword
  hi link @keyword.return Keyword

  hi link @conditional Conditional
  hi link @repeat Repeat
  hi link @debug Debug
  hi link @label Label
  hi link @include Include
  hi link @exception Exception
  " }}}

  " Types {{{
  hi link @type Type
  hi link @type.builtin Type
  hi link @type.qualifier Type
  hi link @type.definition Typedef

  hi link @storageclass StorageClass
  hi link @attribute PreProc
  hi link @field Identifier
  hi link @property Identifier
  " }}}

  " Identifiers {{{
  hi link @variable Normal
  hi link @variable.builtin Special

  hi link @constant Constant
  hi link @constant.builtin Special
  hi link @constant.macro Define

  hi link @namespace Include
  hi link @symbol Identifier
  " }}}

  " Text {{{
  hi link @text Normal
  hi @text.strong gui=bold
  hi @text.emphasis gui=italic
  hi @text.underline gui=underline
  hi link @text.title Title
  hi link @text.literal String
  hi link @text.uri Underlined
  hi link @text.math Special
  hi link @text.environment Macro
  hi link @text.environment.name Type
  hi link @text.reference Constant

  hi link @text.todo Todo
  hi link @text.note SpecialComment
  hi link @text.warning WarningMsg
  hi link @text.danger ErrorMsg
  " }}}

  " Tags {{{
  hi link @tag Tag
  hi link @tag.attribute Identifier
  hi link @tag.delimiter Delimiter
  " }}}
endfun

augroup highlight_old_groups
  autocmd!

  autocmd ColorScheme * :call <SID>HighlightOldGroups()
augroup END

call <SID>HighlightOldGroups()
" }}}
