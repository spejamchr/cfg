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

-- Maps for picking Git stuff
vim.keymap.del("n", "<leader>gc")

vim.keymap.set("n", "<leader>gf", function()
  Snacks.picker.git_log_file()
end, { desc = "Git Current File History" })

vim.keymap.set("n", "<leader>gl", function()
  Snacks.picker.git_log({ cwd = LazyVim.root.git() })
end, { desc = "Git Log" })

vim.keymap.set("n", "<leader>gL", function()
  Snacks.picker.git_log()
end, { desc = "Git Log (cwd)" })

-- Perform 'open' on leaf node, 'expand' on collapsed node, and 'collapse' on
-- expanded node. From fern's docs.
vim.cmd([[
nmap <silent><expr>
      \ <Plug>(fern-action-open-or-expand-or-collapse)
      \ fern#smart#leaf(
      \   "\<Plug>(fern-action-open)",
      \   "\<Plug>(fern-action-expand)",
      \   "\<Plug>(fern-action-collapse)",
      \ )
]])

-- Define my Fern mappings
local function fern_init()
  -- Splits
  vim.keymap.set({ "n" }, "<C-x>", "<Plug>(fern-action-open:split)", {
    buffer = true,
    desc = "Fern: Open in Split",
  })
  vim.keymap.set({ "n" }, "<C-v>", "<Plug>(fern-action-open:vsplit)", {
    buffer = true,
    desc = "Fern: Open in Vsplit",
  })

  -- Navigation
  vim.keymap.set({ "n" }, "-", "<Plug>(fern-action-leave)", {
    buffer = true,
    desc = "Fern: Navigate up the Filesystem",
  })
  vim.keymap.set({ "n" }, "_", "<Plug>(fern-action-enter)", {
    buffer = true,
    desc = "Fern: Enter the directory",
  })
  vim.keymap.set({ "n" }, "r", "<Plug>(fern-action-reload)", {
    buffer = true,
    desc = "Fern: Reload the UI",
  })

  vim.keymap.set(
    { "n" },
    "<Return>",
    "<Plug>(fern-action-open-or-expand-or-collapse)",
    {
      buffer = true,
      desc = "Fern: Open/Expand/Collapse selected",
    }
  )

  -- CRUD
  vim.keymap.set({ "n" }, "<Leader>n", "<Plug>(fern-action-new-path)", {
    buffer = true,
    desc = "Fern: Create new file/dir",
  })
  vim.keymap.set({ "n" }, "<Leader>d", "<Plug>(fern-action-remove)", {
    buffer = true,
    desc = "Fern: Remove selected",
  })
  vim.keymap.set({ "n" }, "<Leader>m", "<Plug>(fern-action-rename)", {
    buffer = true,
    desc = "Fern: Move selected",
  })
  vim.keymap.set({ "n" }, "<Leader>c", "<Plug>(fern-action-copy)", {
    buffer = true,
    desc = "Fern: Copy selected",
  })

  -- Marks
  vim.keymap.set({ "n" }, "<C-n>", "<Plug>(fern-action-mark:toggle)j", {
    buffer = true,
    desc = "Fern: Toggle selection of current and move down",
  })
  vim.keymap.set({ "n" }, "<C-p>", "<Plug>(fern-action-mark:toggle)k", {
    buffer = true,
    desc = "Fern: Toggle selection of current and move up",
  })
  vim.keymap.set({ "n" }, "<C-t>", "<Plug>(fern-action-mark:toggle)", {
    buffer = true,
    desc = "Fern: Toggle selection of current",
  })
  vim.keymap.set({ "n" }, "<C-c>", "<Plug>(fern-action-mark:clear)", {
    buffer = true,
    desc = "Fern: Clear all selections",
  })
end

vim.api.nvim_create_autocmd({ "FileType" }, {
  pattern = { "fern" },
  group = vim.api.nvim_create_augroup("SJC-fern-custom", { clear = true }),
  callback = fern_init,
})
