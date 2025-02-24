-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

function OrganizeImports()
  local bufnr = vim.api.nvim_get_current_buf()
  local params = {
    command = "_typescript.organizeImports",
    arguments = { vim.api.nvim_buf_get_name(bufnr) },
    title = "",
  }
  vim.lsp.buf_request_sync(bufnr, "workspace/executeCommand", params, 500)
end

vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = "*.js,*.jsx,*.ts,*.tsx",
  group = vim.api.nvim_create_augroup("SJC-OrganizeImports", {}),
  callback = OrganizeImports,
})
