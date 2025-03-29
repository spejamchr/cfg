-- vim:fileencoding=utf-8:foldmethod=marker

-- Bootstrap lazy.nvim {{{
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "--branch=stable",
    lazyrepo,
    lazypath,
  })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)
-- }}}

-- Options {{{
-- Use Space as my leader
vim.g.mapleader = " "

-- Fish is great for interactive shells, but for editing use zsh
vim.opt.shell = "/bin/zsh"

-- Always show the signcolumn to prevent the text from bouncing
vim.opt.signcolumn = "yes"

vim.opt.backup = false -- no backup files
vim.opt.writebackup = false -- only in case you don't want a backup file while editing
vim.opt.swapfile = false -- no swap files

-- Tab key inserts 2 spaces normally
vim.opt.tabstop = 2
vim.opt.softtabstop = 0
vim.opt.expandtab = true
vim.opt.shiftwidth = 2
vim.opt.smartindent = true

-- Disable mouse mode
vim.opt.mouse = ""

vim.opt.splitbelow = true
vim.opt.splitright = true

vim.opt.cursorline = true

-- Show incremental commands
vim.opt.inccommand = "split"

-- Persistent undo
vim.opt.undofile = true

-- Set the colorscheme once things have loaded
vim.schedule(function()
  vim.cmd([[
if filereadable(expand("~/.vimrc_background"))
  source ~/.vimrc_background
endif
]])
end)
-- }}}

-- Keymaps {{{
vim.keymap.set({ "n" }, "<Leader>w", "<cmd>w<cr><esc>", { desc = "Save File" })
vim.keymap.set({ "n" }, "-", ":Fern %:h-reveal=%:p<CR>", { desc = "Open Fern" })
vim.keymap.set({ "n" }, "<Leader><space>", function()
  Snacks.picker.files()
end, { desc = "Find file" })

-- Maps for Finding
vim.keymap.set("n", "<Leader>fp", function()
  Snacks.picker.pickers()
end, { desc = "Find a Picker" })

-- Maps for Git stuff
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
-- }}}

-- Autocmds {{{
vim.api.nvim_create_autocmd("VimResized", {
  pattern = "*",
  group = vim.api.nvim_create_augroup("SJC-resize-neovim", {}),
  callback = function()
    vim.cmd("wincmd =")
  end,
})

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

-- Per default, netrw leaves unmodified buffers open. This autocommand
-- deletes netrw's buffer once it's hidden (using ':q', for example)
-- autocmd FileType netrw setlocal bufhidden=delete

vim.api.nvim_create_autocmd("FileType", {
  pattern = "netrw",
  group = vim.api.nvim_create_augroup("SJC-DeleteNetrwBuffers", {}),
  callback = function()
    vim.opt_local.bufhidden = "delete"
  end,
})
-- }}}

-- Setup Plugins with lazy.nvim {{{
require("lazy").setup({
  defaults = {
    version = "*",
  },
  spec = {
    { "RRethy/base16-nvim" },
    {
      "nvim-lualine/lualine.nvim",
      opts = {
        sections = {
          lualine_b = {
            {
              "filetype",
              icon_only = false,
              separator = "",
              padding = { left = 1, right = 0 },
            },
            "%f",
          },
          lualine_c = {
            {
              "diagnostics",
            },
          },
          lualine_y = {
            { "searchcount" },
            { "progress", separator = " ", padding = { left = 1, right = 1 } },
          },
          lualine_z = {
            { "location", padding = { left = 0, right = 1 } },
          },
        },
        inactive_sections = {
          lualine_a = {},
          lualine_c = {},
          lualine_b = { "%f" },
          lualine_x = { "location" },
          lualine_y = {},
          lualine_z = {},
        },
      },
    },
    {
      "echasnovski/mini.surround",
      opts = {
        custom_textobjects = function()
          return {
            f = require("mini.surround").gen_spec.input.treesitter({
              outer = "@call.outer",
              inner = "@call.inner",
            }),
            t = require("mini.surround").gen_spec.input.treesitter({
              outer = "@function.outer",
              inner = "@function.inner",
            }),
          }
        end,
        mappings = {
          add = "ys",
          delete = "ds",
          replace = "cs",
          find = "",
          find_left = "",
          highlight = "",
          update_n_lines = "",
        },
      },
    },
    {
      "folke/flash.nvim",
      event = "VeryLazy",
      ---@type Flash.Config
      opts = {},
      -- stylua: ignore
      keys = {
        { "s", mode = { "n", "x", "o" }, function() require("flash").jump() end, desc = "Flash" },
        { "S", mode = { "n", "x", "o" }, function() require("flash").treesitter() end, desc = "Flash Treesitter" },
        { "r", mode = "o", function() require("flash").remote() end, desc = "Remote Flash" },
        { "R", mode = { "o", "x" }, function() require("flash").treesitter_search() end, desc = "Treesitter Search" },
        { "<c-s>", mode = { "c" }, function() require("flash").toggle() end, desc = "Toggle Flash Search" },
      },
    },
    {
      "folke/snacks.nvim",
      opts = {
        indent = { enabled = true },
        input = { enabled = true },
        notifier = { enabled = true },
        scope = { enabled = true },
        scroll = { enabled = true },
        statuscolumn = { enabled = true },
        toggle = { enabled = true },
        words = { enabled = true },
        picker = {
          win = {
            input = {
              keys = {
                ["<Esc>"] = { "close", mode = { "n", "i" } },
                ["<c-x>"] = { "edit_split", mode = { "i", "n" } },
              },
            },
          },
        },
      },
    },
    {
      "folke/tokyonight.nvim",
      opts = {
        transparent = true,
        styles = {
          sidebars = "transparent",
          floats = "transparent",
        },
      },
    },
    {
      "folke/which-key.nvim",
      event = "VeryLazy",
      opts = {
        preset = "helix",
        -- your configuration comes here
        -- or leave it empty to use the default settings
        -- refer to the configuration section below
      },
      keys = {
        {
          "<leader>?",
          function()
            require("which-key").show({ global = false })
          end,
          desc = "Buffer Local Keymaps (which-key)",
        },
      },
    },
    {
      "stevearc/conform.nvim",
      event = { "BufWritePre" },
      cmd = { "ConformInfo" },
      keys = {
        {
          "<leader>cf",
          function()
            require("conform").format({ async = true })
          end,
          mode = "",
          desc = "Format buffer",
        },
      },
      -- This will provide type hinting with LuaLS
      -- @module "conform"
      -- @type conform.setupOpts
      opts = {
        formatters_by_ft = {
          lua = { "stylua" },
          javascript = { "prettier" },
          typescript = { "prettier" },
          fish = { "fish_indent" },
          cs = { "csharpier" },
        },
        default_format_opts = {
          lsp_format = "fallback",
        },
        format_on_save = { timeout_ms = 500 },
      },
      init = function()
        -- If you want the formatexpr, here is the place to set it
        vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"
      end,
    },
    { "tpope/vim-fugitive" },
    {
      "lambdalisue/vim-fern",
      init = function()
        -- Show hidden files by default
        vim.g["fern#default_hidden"] = 1

        -- Only use my mappings
        vim.g["fern#disable_default_mappings"] = 1

        vim.g["fern#renderer#default#leaf_symbol"] = "| "
        vim.g["fern#renderer#default#collapsed_symbol"] = "+ "
        vim.g["fern#renderer#default#expanded_symbol"] = "- "
      end,
    },
    { "lambdalisue/vim-fern-git-status" },
    { "lambdalisue/vim-fern-hijack" },
    {
      "lewis6991/gitsigns.nvim",
      opts = {
        signs = {
          add = { text = "▎" },
          change = { text = "▎" },
          delete = { text = "" },
          topdelete = { text = "" },
          changedelete = { text = "▎" },
          untracked = { text = "▎" },
        },
        signs_staged = {
          add = { text = "▎" },
          change = { text = "▎" },
          delete = { text = "" },
          topdelete = { text = "" },
          changedelete = { text = "▎" },
        },
        on_attach = function(buffer)
          local gs = package.loaded.gitsigns

          local function map(mode, l, r, desc)
            vim.keymap.set(mode, l, r, { buffer = buffer, desc = desc })
          end
    
          -- stylua: ignore start
          map("n", "]h", function()
            if vim.wo.diff then
              vim.cmd.normal({ "]c", bang = true })
            else
              gs.nav_hunk("next")
            end
          end, "Next Hunk")
          map("n", "[h", function()
            if vim.wo.diff then
              vim.cmd.normal({ "[c", bang = true })
            else
              gs.nav_hunk("prev")
            end
          end, "Prev Hunk")
          map("n", "]H", function() gs.nav_hunk("last") end, "Last Hunk")
          map("n", "[H", function() gs.nav_hunk("first") end, "First Hunk")
          map({ "n", "v" }, "<leader>ghs", ":Gitsigns stage_hunk<CR>", "Stage Hunk")
          map({ "n", "v" }, "<leader>ghr", ":Gitsigns reset_hunk<CR>", "Reset Hunk")
          map("n", "<leader>ghu", gs.undo_stage_hunk, "Undo Stage Hunk")
          map("n", "<leader>ghp", gs.preview_hunk_inline, "Preview Hunk Inline")
          map("n", "<leader>ghb", function() gs.blame_line({ full = true }) end, "Blame Line")
          map("n", "<leader>ghB", function() gs.blame() end, "Blame Buffer")
          map("n", "<leader>ghd", gs.diffthis, "Diff This")
          map("n", "<leader>ghD", function() gs.diffthis("~") end, "Diff This ~")
          map({ "o", "x" }, "ih", ":<C-U>Gitsigns select_hunk<CR>", "GitSigns Select Hunk")
        end,
      },
    },
    { "saghen/blink.cmp" },
  },
  -- Configure any other settings here. See the documentation for more details.
  -- colorscheme that will be used when installing plugins.
  install = { colorscheme = { "default" } },
  -- automatically check for plugin updates
  checker = { enabled = true },
})
-- }}}
