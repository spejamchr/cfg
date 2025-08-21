-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

vim.keymap.set({ "n" }, "<Leader>w", "<cmd>w<cr><esc>", { desc = "Save File" })
vim.keymap.set(
  { "n" },
  "-",
  ":Fern %:h -reveal=%:p<CR>",
  { desc = "Open Fern (File Explorer)" }
)

-- Maps for Finding
vim.keymap.set("n", "<Leader>fp", function()
  Snacks.picker.pickers()
end, { desc = "Find a Picker" })

-- Maps for Git stuff
vim.keymap.del("n", "<leader>gc")

vim.keymap.set(
  "n",
  "<leader>ga",
  ":G blame<CR>",
  { desc = "Git Blame Whole File" }
)

vim.keymap.set("n", "<leader>gf", function()
  Snacks.picker.git_log_file()
end, { desc = "Git Current File History" })

vim.keymap.set("n", "<leader>gl", function()
  Snacks.picker.git_log({ cwd = LazyVim.root.git() })
end, { desc = "Git Log" })

vim.keymap.set("n", "<leader>gL", function()
  Snacks.picker.git_log()
end, { desc = "Git Log (cwd)" })

vim.cmd([[
" Open Fern in the current dir and highlight the current file
" nmap - :Fern %:h -reveal=%:p<CR>

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
]])
