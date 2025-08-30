-- vim:fileencoding=utf-8:foldmethod=marker

vim.g.mapleader = " "

-- Simple option settings {{{
-- fish is great for interactive shells, but for editing use zsh
vim.o.shell = "/bin/zsh"

-- Always show the signcolumn to prevent the text from bouncing
vim.o.signcolumn = "yes"

vim.o.writebackup = false
vim.o.swapfile = false

vim.o.tabstop = 2
vim.o.softtabstop = 2
vim.o.shiftwidth = 2
vim.o.smartindent = true
vim.o.expandtab = true

-- Try line numbers for now
vim.o.number = true

-- /foo -> foo Foo FOO
-- /Foo ->     Foo
vim.o.ignorecase = true
vim.o.smartcase = true

-- More natural splits
vim.o.splitbelow = true
vim.o.splitright = true

-- Give floating windows a rounded border
vim.o.winborder = "rounded"

-- Disable the mouse
vim.o.mouse = ""

-- Highlight the cursor's line
vim.o.cursorline = true

-- Use tree view in netrw directory browser
vim.g.netrw_liststyle = 3
-- No banner in netrw
vim.g.netrw_banner = 0

-- Show incremental commands, like find-and-replace
vim.o.inccommand = "split"

-- Save undo histories
vim.o.undofile = true

-- Show non-printing characters
vim.o.list = true
vim.opt.listchars = { tab = "  ", trail = "·" }

-- If performing an operation that would fail due to unsaved changes in the
-- buffer (like `:q`), instead raise a dialog asking to save the file first.
vim.o.confirm = true

vim.diagnostic.config({
	virtual_lines = true,
	float = {
		source = "if_many",
	},
	jump = {
		float = true,
	},
})

-- Don't show the mode, since it's already in the status line
vim.o.showmode = false
-- }}}

-- Autocommands {{{
local group = vim.api.nvim_create_augroup("init.lua", { clear = true })

-- By default, netrw leaves unmodified buffers open.
vim.api.nvim_create_autocmd({ "FileType" }, {
	desc = "Delete netrw's buffers once they're hidden",
	pattern = "netrw",
	group = group,
	callback = function()
		vim.opt_local.bufhidden = "delete"
	end,
})

vim.api.nvim_create_autocmd({ "VimResized" }, {
	desc = "Keep splits equal when resizing neovim",
	group = group,
	callback = function()
		vim.cmd("wincmd =")
	end,
})

vim.api.nvim_create_autocmd({ "BufWritePre" }, {
	desc = "Organize TS/JS imports on save",
	pattern = { "*.ts*", "*.js*" },
	group = group,
	callback = function()
		vim.cmd("TSToolsOrganizeImports sync")
	end,
})

vim.api.nvim_create_autocmd({ "TextYankPost" }, {
	desc = "Highlight when yanking text",
	group = group,
	callback = function()
		vim.hl.on_yank()
	end,
})

vim.api.nvim_create_autocmd({ "FileType" }, {
	desc = "Initialize Fern",
	pattern = "fern",
	group = group,
	callback = function()
		-- Perform 'open' on leaf node, 'expand' on collapsed node, and 'collapse'
		-- on expanded node. From fern's docs.
		vim.keymap.set("n", "<Return>", function()
			return vim.fn["fern#smart#leaf"](
				"<Plug>(fern-action-open)",
				"<Plug>(fern-action-expand)",
				"<Plug>(fern-action-collapse)"
			)
		end, {
			desc = "Open/Expand/Collapse selected",
			buffer = true,
			silent = true,
			expr = true,
			remap = true,
		})

		-- My mappings --

		-- Splits
		vim.keymap.set("n", "<C-s>", "<Plug>(fern-action-open:split)", {
			desc = "Open in a split",
			buffer = true,
		})
		vim.keymap.set("n", "<C-v>", "<Plug>(fern-action-open:vsplit)", {
			desc = "Open in a vsplit",
			buffer = true,
		})

		-- Navigation
		vim.keymap.set("n", "-", "<Plug>(fern-action-leave)", {
			desc = "Navigate up the Filesystem",
			buffer = true,
		})
		vim.keymap.set("n", "_", "<Plug>(fern-action-enter)", {
			desc = "Enter the directory",
			buffer = true,
		})
		vim.keymap.set("n", "r", "<Plug>(fern-action-reload)", {
			desc = "Reload the UI",
			buffer = true,
		})

		-- CRUD
		vim.keymap.set("n", "<Leader>n", "<Plug>(fern-action-new-path)", {
			buffer = true,
			desc = "Create new file/dir",
		})
		vim.keymap.set("n", "<Leader>d", "<Plug>(fern-action-remove)", {
			buffer = true,
			desc = "Remove selected",
		})
		vim.keymap.set("n", "<Leader>m", "<Plug>(fern-action-rename)", {
			buffer = true,
			desc = "Move selected",
		})
		vim.keymap.set("n", "<Leader>c", "<Plug>(fern-action-copy)", {
			buffer = true,
			desc = "Copy selected",
		})

		-- Marks
		vim.keymap.set("n", "<C-n>", "<Plug>(fern-action-mark:toggle)j", {
			buffer = true,
			desc = "Toggle selection of current and move down",
		})
		vim.keymap.set("n", "<C-p>", "<Plug>(fern-action-mark:toggle)k", {
			buffer = true,
			desc = "Toggle selection of current and move up",
		})
		vim.keymap.set("n", "<C-t>", "<Plug>(fern-action-mark:toggle)", {
			buffer = true,
			desc = "Toggle selection of current",
		})
		vim.keymap.set("n", "<C-c>", "<Plug>(fern-action-mark:clear)", {
			buffer = true,
			desc = "Clear all selections",
		})
	end,
})
-- }}}

-- Keymaps {{{
-- Use `CTRL+{h,j,k,l}` to navigate windows from normal, insert, and terminal modes:
vim.keymap.set("n", "<C-h>", "<C-w>h", { desc = "Nav to buffer ←" })
vim.keymap.set("n", "<C-j>", "<C-w>j", { desc = "Nav to buffer ↓" })
vim.keymap.set("n", "<C-k>", "<C-w>k", { desc = "Nav to buffer ↑" })
vim.keymap.set("n", "<C-l>", "<C-w>l", { desc = "Nav to buffer →" })
vim.keymap.set({ "t", "i" }, "<C-h>", "<C-\\><C-n><C-w>h", { desc = "Nav to buffer ←" })
vim.keymap.set({ "t", "i" }, "<C-j>", "<C-\\><C-n><C-w>j", { desc = "Nav to buffer ↓" })
vim.keymap.set({ "t", "i" }, "<C-k>", "<C-\\><C-n><C-w>k", { desc = "Nav to buffer ↑" })
vim.keymap.set({ "t", "i" }, "<C-l>", "<C-\\><C-n><C-w>l", { desc = "Nav to buffer →" })

-- Use <Esc> to exit terminal mode
vim.keymap.set("t", "<Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })

-- Use <Esc> to clear search results in normal mode
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>", { desc = "Clear search results" })

vim.keymap.set("n", "<leader>tl", function()
	local new_config = not vim.diagnostic.config().virtual_lines
	vim.diagnostic.config({ virtual_lines = new_config })
end, { desc = "Toggle Diagnostic Virtual Lines" })

vim.keymap.set("n", "<Leader>w", "<cmd>w<CR>", { desc = "Write current file" })

vim.keymap.set("n", "<Leader>to", "<cmd>TSToolsOrganizeImports<CR>", { desc = "Organize TS Imports" })

vim.keymap.set("n", "-", "<cmd>Fern %:h -reveal=%:p<CR>", { desc = "Open Fern" })
-- }}}

-- Bootstrap lazy.nvim {{{
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
	local lazyrepo = "https://github.com/folke/lazy.nvim.git"
	local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
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

-- Install Packages {{{
require("lazy").setup({
	install = { colorscheme = { "base16-horizon-terminal-dark" } },
	checker = { enabled = true },
	rocks = { enabled = false },
	ui = {
		border = "rounded",
		backdrop = 100, -- hide the opacity to remove its border
	},

	spec = {

		{
			"folke/which-key.nvim",
			event = "VeryLazy",
			opts = {},
		},

		{
			"ibhagwan/fzf-lua",
			event = "VeryLazy",
			opts = function()
				local fzflua = require("fzf-lua")
				local map = function(lhs, rhs, desc)
					vim.keymap.set("n", lhs, rhs, { desc = desc })
				end

				map("<Leader><Leader>", fzflua.files, "Find File")
				map("<Leader>f", fzflua.files, "Find File")
				map("<Leader>sf", fzflua.files, "Search in Files")

				map("<Leader>sg", fzflua.grep_cword, "Search for the word under the cursor")
				map("<Leader>sc", fzflua.commands, "Search in Commands")
				map("<Leader>sb", fzflua.buffers, "Search in Buffers")
				map("<Leader>so", fzflua.oldfiles, "Search in Old Files")
				map("<Leader>sh", fzflua.helptags, "Search in Help")
				map("<Leader>ss", fzflua.builtin, "Search in Searchers")

				map("<Leader>sr", fzflua.resume, "Resume last search")

				-- Use FzfLua for LSP stuff
				-- Prefer custom keymaps that don't require double-tapping with the same
				-- finger (I don't like the default "gr" key combo)
				map("<Leader>ld", fzflua.lsp_definitions, "[LSP] Definitions")
				map("<Leader>lt", fzflua.lsp_typedefs, "[LSP] Type Definitions")
				map("<Leader>li", fzflua.lsp_implementations, "[LSP] Implementations")
				map("<Leader>lr", fzflua.lsp_references, "[LSP] References")
				map("<Leader>la", fzflua.lsp_code_actions, "[LSP] Code Actions")

				return {
					"border-fused",
					"hide",
				}
			end,
		},

		{
			"nvim-mini/mini.surround",
			version = false,
			opts = {
				mappings = {
					add = "gsa", -- Add surrounding in Normal and Visual modes
					delete = "gsd", -- Delete surrounding
					find = "gsf", -- Find surrounding (to the right)
					find_left = "gsF", -- Find surrounding (to the left)
					highlight = "gsh", -- Highlight surrounding
					replace = "gsr", -- Replace surrounding
					update_n_lines = "gsn", -- Update `n_lines`

					suffix_last = "l", -- Suffix to search with "prev" method
					suffix_next = "n", -- Suffix to search with "next" method
				},
			},
		},

		{
			"folke/snacks.nvim",
			priority = 1000,
			lazy = false,
			---@type snacks.Config
			opts = {
				image = { enabled = true },
				input = { enabled = true },
			},
		},

		{
			"folke/ts-comments.nvim",
			event = "VeryLazy",
			opts = {},
		},

		{
			"echasnovski/mini.pairs",
			event = "VeryLazy",
			opts = {
				modes = { insert = true, command = true, terminal = false },
				-- skip autopair when next character is one of these
				skip_next = [=[[%w%%%'%[%"%.%`%$]]=],
				-- skip autopair when the cursor is inside these treesitter nodes
				skip_ts = { "string" },
				-- skip autopair when next character is closing pair
				-- and there are more closing pairs than opening pairs
				skip_unbalanced = true,
				-- better deal with markdown code blocks
				markdown = true,
			},
		},

		{
			"folke/flash.nvim",
			event = "VeryLazy",
			---@type Flash.Config
			opts = {},
			keys = {
				{
					"s",
					mode = { "n", "x", "o" },
					function()
						require("flash").jump()
					end,
					desc = "Flash",
				},
			},
		},

		{
			"lewis6991/gitsigns.nvim",
			event = "VeryLazy",
			keys = {
				{ "]h", ":Gitsigns next_hunk<CR>", desc = "Next Git Hunk" },
				{ "[h", ":Gitsigns prev_hunk<CR>", desc = "Previous Git Hunk" },
			},
		},

		{
			"folke/todo-comments.nvim",
			lazy = false,
			dependencies = { "nvim-lua/plenary.nvim" },
			opts = {},
		},

		-- Even fewer distractions
		{ "junegunn/goyo.vim", event = "VeryLazy" },

		-- LSP Stuff. Thanks Mason!
		{
			"mason-org/mason-lspconfig.nvim",
			opts = {
				ensure_installed = {
					"jsonls",
					"omnisharp",
					"rust_analyzer",
					"solargraph",
					"tailwindcss",
				},
			},
			dependencies = {
				{ "mason-org/mason.nvim", opts = {} },
				"neovim/nvim-lspconfig",
			},
		},

		-- TS doesn't have a great LSP situation. It needs an adapter.
		{
			"pmizio/typescript-tools.nvim",
			event = "VeryLazy",
			dependencies = { "nvim-lua/plenary.nvim", "neovim/nvim-lspconfig" },
			opts = {},
		},

		-- Improve the LSP experience in my init.lua
		{
			"folke/lazydev.nvim",
			ft = "lua", -- only load on lua files
			opts = {
				library = {
					"lazy.nvim",
				},
			},
		},

		-- Format files
		{
			"stevearc/conform.nvim",
			opts = {
				formatters_by_ft = {
					lua = { "stylua" },
					rust = { "rustfmt", lsp_format = "fallback" },
					javascript = { "prettier" },
					typescript = { "prettier" },
				},
				format_on_save = {
					timeout_ms = 500,
					lsp_format = "fallback",
				},
			},
		},

		-- Completions
		{
			"saghen/blink.cmp",
			-- optional: provides snippets for the snippet source
			dependencies = { "rafamadriz/friendly-snippets" },
			-- use a release tag to download pre-built binaries
			version = "1.*",
			-- AND/OR build from source, requires nightly: https://rust-lang.github.io/rustup/concepts/channels.html#working-with-nightly-rust
			-- build = 'cargo build --release',
			-- If you use nix, you can build from source using latest nightly rust with:
			-- build = 'nix run .#build-plugin',
			---@module 'blink.cmp'
			---@type blink.cmp.Config
			opts = {
				keymap = { preset = "default" },
				completion = {
					accept = {
						auto_brackets = {
							enabled = true,
						},
					},
					menu = {
						draw = {
							treesitter = { "lsp" },
						},
					},
					documentation = { auto_show = true },
					ghost_text = {
						enabled = true,
					},
				},
				signature = { enabled = true },
				fuzzy = { implementation = "prefer_rust_with_warning" },
				sources = {
					-- add lazydev to your completion providers
					default = { "lazydev", "lsp", "path", "snippets", "buffer" },
					providers = {
						lazydev = {
							name = "LazyDev",
							module = "lazydev.integrations.blink",
							-- make lazydev completions top priority (see `:h blink.cmp`)
							score_offset = 100,
						},
					},
				},
			},
			opts_extend = { "sources.default" },
		},

		-- Treesitter Syntax Highlighting
		{
			"nvim-treesitter/nvim-treesitter",
			lazy = false,
			build = ":TSUpdate",
			main = "nvim-treesitter.configs", -- Sets main module to use for opts
			opts = {
				auto_install = true,
				highlight = {
					enable = true,
				},
			},
		},

		-- Statusline
		{
			"nvim-lualine/lualine.nvim",
			lazy = false,
			opts = {
				theme = "auto",
			},
		},

		-- Colorscheme
		{ "RRethy/base16-nvim", lazy = false, priority = 1000 },

		-- lazy.nvim
		{
			"folke/noice.nvim",
			event = "VeryLazy",
			opts = {
				-- add any options here
			},
			dependencies = {
				"MunifTanjim/nui.nvim",
				-- OPTIONAL:
				--   `nvim-notify` is only needed, if you want to use the notification view.
				--   If not available, we use `mini` as the fallback
				-- "rcarriga/nvim-notify",
			},
		},

		-- Git
		{ "tpope/vim-fugitive" },

		-- File browsing
		{
			"lambdalisue/vim-fern",
			lazy = false,
			init = function()
				-- Show hidden files by default
				vim.g["ferm#default_hidden"] = 1

				-- " Only use my mappings
				vim.g["fern#disable_default_mappings"] = 1

				vim.g["fern#renderer#default#leaf_symbol"] = "| "
				vim.g["fern#renderer#default#collapsed_symbol"] = "+ "
				vim.g["fern#renderer#default#expanded_symbol"] = "- "
			end,
		},
		{ "lambdalisue/vim-fern-git-status", lazy = false },
		{ "lambdalisue/vim-fern-hijack", lazy = false },
	},
})
-- }}}

-- Set colorscheme {{{
vim.cmd([[
if filereadable(expand("~/.vimrc_background"))
  source ~/.vimrc_background
endif
]])
-- }}}
