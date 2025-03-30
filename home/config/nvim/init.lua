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

-- Add a border to floating windows
vim.opt.winborder = "rounded"

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
vim.keymap.set({ "n" }, "-", ":Oil<CR>", { desc = "Open File Explorer" })

local function navving()
  local function m(lhs, rhs, desc)
    vim.keymap.set({ "n", "i", "x" }, lhs, rhs, { desc = "Nav to " .. desc })
  end
  m("<C-l>", "<CMD>wincmd l<CR>", "right window")
  m("<C-h>", "<CMD>wincmd h<CR>", "left window")
  m("<C-k>", "<CMD>wincmd k<CR>", "window above")
  m("<C-j>", "<CMD>wincmd j<CR>", "window below")
end
navving()

-- stylua: ignore
local function finding()
  local function m(lhs, rhs, desc)
    vim.keymap.set("n", lhs, rhs, { desc = "Find " .. desc })
  end
  m("<Leader><space>", function() Snacks.picker.files() end, "File")
  m("<Leader>ff", function() Snacks.picker.files() end, "File")
  m("<Leader>fb", function() Snacks.picker.buffers() end, "Buffers")
  m("<Leader>fc", function() Snacks.picker.files({ cwd = vim.fn.stdpath("config") }) end, "Config File")
  m("<Leader>fp", function() Snacks.picker.pickers() end, "Picker")
  m("<Leader>fr", function() Snacks.picker.recent() end, "Picker")
  m("<Leader>sg", function() Snacks.picker.grep() end, "with Grep")
end
finding()

-- stylua: ignore
local function gitting()
  local function m(lhs, rhs, desc)
    vim.keymap.set("n", lhs, rhs, { desc = "Git " .. desc })
  end
  m("<leader>ga", ":G blame<CR>", "Blame All File")
  m("<leader>gf", function() Snacks.picker.git_log_file() end, "Current File History")
  m("<leader>gl", function() Snacks.picker.git_log({ cwd = LazyVim.root.git() }) end, "Log")
  m("<leader>gL", function() Snacks.picker.git_log() end, "Log (cwd)")
end
gitting()

-- stylua: ignore
local function lsping()
  local function m(lhs, rhs, desc)
    vim.keymap.set("n", lhs, rhs, { desc = "LSP " .. desc })
  end
  m("gd", function() Snacks.picker.lsp_definitions() end, "Definitions")
  m("gr", function() Snacks.picker.lsp_references() end, "References")
  m("<Leader>ca", vim.lsp.buf.code_action, "Code Action")
  m("gn", vim.lsp.buf.rename, "Rename")
end
lsping()
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

-- LSP {{{
vim.lsp.config["luals"] = {
  cmd = { "lua-language-server" },
  filetypes = { "lua" },
  root_markers = { ".luarc.json", ".luarc.jsonc" },
  settings = {
    Lua = {
      runtime = {
        version = "LuaJIT",
      },
      workspace = {
        library = vim.tbl_extend(
          "keep",
          { vim.env.VIMRUNTIME, "${3rd}/luv/library" },
          vim.api.nvim_get_runtime_file("", true)
        ),
      },
      telemetry = {
        enable = false,
      },
    },
  },
}
vim.lsp.enable("luals")

vim.lsp.config["ts_ls"] = {
  cmd = { "typescript-language-server", "--stdio" },
  filetypes = {
    "typescript",
    "typescriptreact",
    "javascript",
    "javascriptreact",
  },
  root_markers = { ".git" },
  single_file_support = true,
  settings = {
    includeInlayParameterNameHints = "all",
    includeInlayParameterNameHintsWhenArgumentMatchesName = true,
    includeInlayFunctionParameterTypeHints = true,
    includeInlayVariableTypeHints = true,
    includeInlayPropertyDeclarationTypeHints = true,
    includeInlayFunctionLikeReturnTypeHints = true,
    includeInlayEnumMemberValueHints = true,
    importModuleSpecifierPreference = "relative",
    importModuleSpecifierEnding = "minimal",
  },
}
vim.lsp.enable("ts_ls")

vim.diagnostic.config({ virtual_lines = true })
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
      "stevearc/oil.nvim",
      ---@module 'oil'
      ---@type oil.SetupOpts
      opts = {
        watch_for_changes = true,
        keymaps = {
          ["<C-x>"] = { "actions.select", opts = { horizontal = true } },
          ["<C-v>"] = { "actions.select", opts = { vertical = true } },
          ["<C-l>"] = false,
          ["<C-h>"] = false,
        },
      },
      lazy = false,
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
          add = "gsa",
          delete = "gsd",
          replace = "gsc",
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
    {
      "saghen/blink.cmp",
      ---@module 'blink.cmp'
      ---@type blink.cmp.Config
      opts = {
        keymap = { preset = "default" },
        completion = { documentation = { auto_show = true } },
      },
    },
  },
  -- Configure any other settings here. See the documentation for more details.
  -- colorscheme that will be used when installing plugins.
  install = { colorscheme = { "default" } },
  -- automatically check for plugin updates
  checker = { enabled = true },
})
-- }}}
