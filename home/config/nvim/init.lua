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
end, { desc = "Toggle Virtual Lines" })

vim.keymap.set("n", "<leader>th", function()
	vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())
end, { desc = "Toggle Inlay Hints" })

vim.keymap.set("n", "<Leader>w", "<cmd>w<CR>", { desc = "Write current file" })

vim.keymap.set("n", "-", "<cmd>Fern %:h -reveal=%:p<CR>", { desc = "Open Fern" })

local visual_range = function()
	local c = vim.fn.getpos(".")[2]
	local v = vim.fn.getpos("v")[2]
	local a = math.min(c, v)
	local b = math.max(c, v)
	return a .. "," .. b
end

vim.keymap.set("n", "<Leader>gb", "<cmd>GBrowse<CR>", { desc = "Open current file/thing in browser" })

vim.keymap.set("v", "<Leader>gb", function()
	vim.cmd(visual_range() .. "GBrowse")
end, { desc = "Open current file/thing in browser" })

vim.keymap.set("n", "<Leader>gy", "<cmd>GBrowse<CR>", { desc = "Copy browser link to current file/thing" })

vim.keymap.set("v", "<Leader>gy", function()
	vim.cmd(visual_range() .. "GBrowse!")
end, { desc = "Copy browser link to current file/thing" })

-- Stay in Visual mode when indenting
vim.keymap.set("v", ">", ">gv", { desc = "Indent current selection" })
vim.keymap.set("v", "<", "<gv", { desc = "Un-indent current selection" })
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
local tinty_current = vim.system({ "tinty", "current" }, { text = true }):wait().stdout

require("lazy").setup({
	install = { colorscheme = { tinty_current, "default" } },
	checker = { enabled = true },
	rocks = { enabled = false },
	ui = {
		border = "rounded",
		backdrop = 100, -- hide the backdrop to remove its border
	},

	spec = {

		-- folke/which-key.nvim {{{
		-- 💥 Create key bindings that stick. WhichKey helps you remember your Neovim
		-- keymaps, by showing available keybindings in a popup as you type.
		{
			"folke/which-key.nvim",
			event = "VeryLazy",
			opts = {},
		},
		-- }}}

		-- ibhagwan/fzf-lua {{{
		-- Improved fzf.vim written in lua
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

				map("<Leader>st", fzflua.live_grep, "Search with live grep")
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

				fzflua.register_ui_select()

				return {
					"border-fused",
					"hide",
				}
			end,
		},
		-- }}}

		-- nvim-mini/mini.surround {{{
		-- Neovim Lua plugin with fast and feature-rich surround actions. Part of
		-- 'mini.nvim' library.
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
		-- }}}

		-- nvim-mini/mini.pairs {{{
		-- Neovim Lua plugin to automatically manage character pairs. Part of
		-- 'mini.nvim' library.
		{
			"nvim-mini/mini.pairs",
			event = "VeryLazy",
			opts = {
				modes = { insert = true, command = false, terminal = false },
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
		-- }}}

		-- folke/snacks.nvim {{{
		-- 🍿 A collection of QoL plugins for Neovim
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
		-- }}}

		-- folke/ts-comments.nvim {{{
		-- Tiny plugin to enhance Neovim's native comments
		{
			"folke/ts-comments.nvim",
			event = "VeryLazy",
			opts = {},
		},
		-- }}}

		-- folke/flash.nvim {{{
		-- Navigate your code with search labels, enhanced character motions and
		-- Treesitter integration
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
		-- }}}

		-- lewis6991/gitsigns.nvim {{{
		-- Git integration for buffers
		{
			"lewis6991/gitsigns.nvim",
			event = "VeryLazy",
			-- Copied from the docs
			-- https://github.com/lewis6991/gitsigns.nvim?tab=readme-ov-file#-keymaps
			on_attach = function(bufnr)
				local gitsigns = require("gitsigns")

				local function map(mode, l, r, opts)
					opts = opts or {}
					opts.buffer = bufnr
					vim.keymap.set(mode, l, r, opts)
				end

				-- Navigation
				map("n", "]c", function()
					if vim.wo.diff then
						vim.cmd.normal({ "]c", bang = true })
					else
						gitsigns.nav_hunk("next")
					end
				end)

				map("n", "[c", function()
					if vim.wo.diff then
						vim.cmd.normal({ "[c", bang = true })
					else
						gitsigns.nav_hunk("prev")
					end
				end)

				-- Actions
				map("n", "<leader>hs", gitsigns.stage_hunk)
				map("n", "<leader>hr", gitsigns.reset_hunk)

				map("v", "<leader>hs", function()
					gitsigns.stage_hunk({ vim.fn.line("."), vim.fn.line("v") })
				end)

				map("v", "<leader>hr", function()
					gitsigns.reset_hunk({ vim.fn.line("."), vim.fn.line("v") })
				end)

				map("n", "<leader>hS", gitsigns.stage_buffer)
				map("n", "<leader>hR", gitsigns.reset_buffer)
				map("n", "<leader>hp", gitsigns.preview_hunk)
				map("n", "<leader>hi", gitsigns.preview_hunk_inline)

				map("n", "<leader>hb", function()
					gitsigns.blame_line({ full = true })
				end)

				map("n", "<leader>hd", gitsigns.diffthis)

				map("n", "<leader>hD", function()
					gitsigns.diffthis("~")
				end)

				map("n", "<leader>hQ", function()
					gitsigns.setqflist("all")
				end)
				map("n", "<leader>hq", gitsigns.setqflist)

				-- Toggles
				map("n", "<leader>tb", gitsigns.toggle_current_line_blame)
				map("n", "<leader>tw", gitsigns.toggle_word_diff)

				-- Text object
				map({ "o", "x" }, "ih", gitsigns.select_hunk)
			end,
			keys = {
				{ "]h", "<cmd>Gitsigns next_hunk<CR>", desc = "Next Git Hunk" },
				{ "[h", "<cmd>Gitsigns prev_hunk<CR>", desc = "Previous Git Hunk" },
			},
		},
		-- }}}

		-- folke/todo-comments.nvim {{{
		-- ✅ Highlight, list and search todo comments in your projects
		{
			"folke/todo-comments.nvim",
			lazy = false,
			dependencies = { "nvim-lua/plenary.nvim" },
			opts = {},
		},
		-- }}}

		-- junegunn/goyo.vim {{{
		-- 🌷 Distraction-free writing in Vim
		{ "junegunn/goyo.vim", event = "VeryLazy" },
		--- }}}

		-- mason-org/mason-lspconfig.nvim {{{
		-- LSP Stuff. Thanks Mason!
		-- Extension to mason.nvim that makes it easier to use lspconfig with
		-- mason.nvim.
		{
			"mason-org/mason-lspconfig.nvim",
			opts = {},
			dependencies = {
				{ "mason-org/mason.nvim", opts = {} },
				"neovim/nvim-lspconfig",
				"WhoIsSethDaniel/mason-tool-installer.nvim",
				"saghen/blink.cmp",
				-- Useful status updates for LSP.
				{ "j-hui/fidget.nvim", opts = {} },
			},
			config = function()
				vim.api.nvim_create_autocmd("LspAttach", {
					desc = "Configure LSP stuff",
					group = vim.api.nvim_create_augroup("kickstart-lsp-attach", { clear = true }),
					callback = function()
						-- Try line numbers for now, but only when LSP is attached (when I'm editing code)
						vim.api.nvim_set_option_value("number", true, { scope = "local" })
					end,
				})

				local capabilities = require("blink.cmp").get_lsp_capabilities()

				local servers = {
					jsonls = {},
					omnisharp = {},
					tailwindcss = {},
					rust_analyzer = {},
					solargraph = {},
					["typescript-language-server"] = {},
					lua_ls = {
						-- cmd = { ... },
						-- filetypes = { ... },
						-- capabilities = {},
						settings = {
							Lua = {
								completion = {
									callSnippet = "Replace",
								},
								-- You can toggle below to ignore Lua_LS's noisy `missing-fields`
								-- warnings
								-- diagnostics = { disable = { 'missing-fields' } },
							},
						},
					},
				}

				local other_tools = {
					"stylua",
					"prettier",
					"biome",
				}

				local ensure_installed = vim.tbl_keys(servers)
				vim.list_extend(ensure_installed, other_tools)
				require("mason-tool-installer").setup({ ensure_installed = ensure_installed })

				require("mason-lspconfig").setup({
					ensure_installed = {}, -- Use mason-tool-installer instead
					automatic_installation = false, -- Only install stuff from the init.lua
					handlers = {
						function(server_name)
							local server = servers[server_name] or {}
							-- This handles overriding only values explicitly passed by the server
							-- configuration above. Useful when disabling certain features of
							-- an LSP (for example, turning off formatting for ts_ls)
							server.capabilities =
								vim.tbl_deep_extend("force", {}, capabilities, server.capabilities or {})
							require("lspconfig")[server_name].setup(server)
						end,
					},
				})
			end,
		},
		-- }}}

		-- folke/lazydev.nvim {{{
		--  Faster LuaLS setup for Neovim
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
		-- }}}

		-- stevearc/conform.nvim {{{
		-- Lightweight yet powerful formatter plugin for Neovim
		{
			"stevearc/conform.nvim",
			init = function()
				vim.o.formatexpr = "v:lua.require('conform').formatexpr()"
			end,
			opts = {
				formatters_by_ft = {
					lua = { "stylua" },
					rust = { "rustfmt", lsp_format = "fallback" },
					javascript = { "biome-organize-imports", "prettier" },
					typescript = { "biome-organize-imports", "prettier" },
					typescriptreact = { "biome-organize-imports", "prettier" },
					javascriptreact = { "biome-organize-imports", "prettier" },
					yaml = { "prettier" },
				},
				format_on_save = {
					timeout_ms = 500,
					lsp_format = "fallback",
				},
			},
		},
		-- }}}

		-- saghen/blink.cmp {{{
		-- Performant, batteries-included completion plugin for Neovim
		{
			"saghen/blink.cmp",
			-- optional: provides snippets for the snippet source
			dependencies = { "rafamadriz/friendly-snippets" },
			-- use a release tag to download pre-built binaries
			version = "1.*",
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
					default = { "lsp", "path", "snippets", "buffer" },
					per_filetype = {
						lua = { inherit_defaults = true, "lazydev" },
					},
					providers = {
						lazydev = {
							name = "LazyDev",
							module = "lazydev.integrations.blink",
							-- make lazydev completions top priority (see `:h blink.cmp`)
							score_offset = 100,
						},
					},
				},
				cmdline = {
					keymap = { preset = "inherit" },
					enabled = true,
					completion = {
						menu = {
							auto_show = true,
						},
					},
				},
			},
			opts_extend = { "sources.default" },
		},
		-- }}}

		-- nvim-treesitter/nvim-treesitter {{{
		-- Nvim Treesitter configurations and abstraction layer
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
		-- }}}

		-- nvim-lualine/lualine.nvim {{{
		-- A blazing fast and easy to configure neovim statusline plugin written in
		-- pure lua.
		{
			"nvim-lualine/lualine.nvim",
			lazy = false,
			opts = {
				options = {
					theme = "auto",
				},
				sections = {
					lualine_a = { "mode" },
					lualine_b = {
						{ "branch", icons_enabled = false },
						{
							"diff",
							source = function()
								-- https://github.com/nvim-lualine/lualine.nvim/wiki/Component-snippets#using-external-source-for-diff
								local gitsigns = vim.b.gitsigns_status_dict
								if gitsigns then
									return {
										added = gitsigns.added,
										modified = gitsigns.changed,
										removed = gitsigns.removed,
									}
								end
							end,
						},
						"diagnostics",
					},
					lualine_c = {
						{
							-- Filename, with pretty paths for Fern buffers
							function()
								if vim.bo.filetype == "fern" then
									local filepath = vim.api.nvim_buf_get_name(0)
									local found, _, path = string.find(filepath, "^fern://......../file://(.*)%$$")
									if found then
										return vim.fn.fnamemodify(path, ":~:.")
									else
										return filepath
									end
								else
									return vim.fn.fnamemodify("%f", ":~:.")
								end
							end,
						},
					},
					lualine_x = { "filetype" },
					lualine_y = { "progress" },
					lualine_z = { "location" },
				},
				inactive_sections = {
					lualine_c = { "%f" },
					lualine_x = { "location" },
				},
			},
		},
		-- }}}

		-- tinted-theming/tinted-nvim {{{
		-- Neovim plugin for building tinted-theming colorscheme. Includes support
		-- for Treesitter and LSP highlight groups.
		{
			"tinted-theming/tinted-nvim",
			lazy = false,
			priority = 1000,
			config = function()
				require("tinted-colorscheme").setup(nil, {
					supports = {
						tinty = true,
						live_reload = false,
					},
				})

				vim.schedule(function()
					vim.cmd([[
            if filereadable(expand("~/.vimrc_background"))
              source ~/.vimrc_background
            endif
          ]])
				end)
			end,
		},
		-- }}}

		-- tpope/vim-fugitive {{{
		-- fugitive.vim: A Git wrapper so awesome, it should be illegal
		{ "tpope/vim-fugitive", dependencies = { "tpope/vim-rhubarb" } },
		-- }}}

		-- lambdalisue/vim-fern {{{
		-- 🌿 General purpose asynchronous tree viewer written in Pure Vim script
		{
			"lambdalisue/vim-fern",
			lazy = false,
			init = function()
				-- Show hidden files by default
				vim.g["fern#default_hidden"] = 1

				-- " Only use my mappings
				vim.g["fern#disable_default_mappings"] = 1

				vim.g["fern#renderer#default#leaf_symbol"] = "| "
				vim.g["fern#renderer#default#collapsed_symbol"] = "+ "
				vim.g["fern#renderer#default#expanded_symbol"] = "- "
			end,
			dependencies = {
				{ "lambdalisue/vim-fern-git-status", lazy = false },
				{ "lambdalisue/vim-fern-hijack", lazy = false },
			},
		},
		-- }}}
	},
})
-- }}}
