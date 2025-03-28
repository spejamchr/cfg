return {
  { "akinsho/bufferline.nvim", enabled = false },
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
        -- add = "ys",
        -- delete = "ds",
        -- replace =  "cs" ,
      },
    },
  },
  {
    "folke/snacks.nvim",
    opts = {
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
      explorer = {
        enabled = false,
      },
    },
  },
  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = {
        lua = { "stylua" },
        fish = { "fish_indent" },
        sh = { "shfmt" },
        cs = { "csharpier" },
      },
    },
  },
  { "tpope/vim-fugitive" },
  { "lambdalisue/vim-fern" },
  { "lambdalisue/vim-fern-git-status" },
  { "lambdalisue/vim-fern-hijack" },
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
    "saghen/blink.cmp",
    version = "1.*",
    opts = {
      keymap = {
        preset = "default",
      },
      fuzzy = { implementation = "prefer_rust_with_warning" },
    },
  },
}
