-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

-- Show hidden files by default
vim.g["fern#default_hidden"] = 1

-- Only use my mappings
vim.g["fern#disable_default_mappings"] = 1

vim.g["fern#renderer#default#leaf_symbol"] = "| "
vim.g["fern#renderer#default#collapsed_symbol"] = "+ "
vim.g["fern#renderer#default#expanded_symbol"] = "- "

-- Don't be smart with my root dir - Use whereever I opened the editor
vim.g.root_spec = { "cwd" }

-- Disable mouse mode
vim.opt.mouse = ""

vim.opt.number = false
vim.opt.relativenumber = false
vim.opt.wrap = true
vim.opt.scrolloff = 0
vim.opt.sidescrolloff = 0

-- Use the tree view in Netrw
vim.g.netrw_liststyle = 3
