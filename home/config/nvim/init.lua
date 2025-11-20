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

-- For empty lines after the end of the file, show nothing instead of tildes
vim.opt.fillchars = { eob = " " }

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
local init_lua_group = vim.api.nvim_create_augroup("init.lua", { clear = true })

-- By default, netrw leaves unmodified buffers open.
vim.api.nvim_create_autocmd({ "FileType" }, {
	desc = "Delete netrw's buffers once they're hidden",
	pattern = "netrw",
	group = init_lua_group,
	callback = function()
		vim.opt_local.bufhidden = "delete"
	end,
})

vim.api.nvim_create_autocmd({ "VimResized" }, {
	desc = "Keep splits equal when resizing neovim",
	group = init_lua_group,
	callback = function()
		vim.cmd("wincmd =")
	end,
})

vim.api.nvim_create_autocmd({ "TextYankPost" }, {
	desc = "Highlight when yanking text",
	group = init_lua_group,
	callback = function()
		vim.hl.on_yank()
	end,
})

vim.api.nvim_create_autocmd({ "FileType" }, {
	desc = "Initialize Fern",
	pattern = "fern",
	group = init_lua_group,
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

vim.api.nvim_create_autocmd("LspAttach", {
	desc = "Set line numbers",
	group = init_lua_group,
	callback = function()
		-- Try line numbers for now, but only when LSP is attached (when I'm editing code)
		vim.api.nvim_set_option_value("number", true, { scope = "local" })
	end,
})

vim.api.nvim_create_autocmd("LspAttach", {
	desc = "Setup Markdown Oxide command",
	group = init_lua_group,
	callback = function(ev)
		local client = vim.lsp.get_client_by_id(ev.data.client_id)

		if client == nil or client.name ~= "markdown_oxide" then
			return
		end

		-- Set up daily command & hotkeys

		vim.keymap.set("n", "<Leader>ot", "<cmd>LspToday<CR>", { desc = "Open today's note" })
		vim.keymap.set("n", "<Leader>om", "<cmd>LspTomorrow<CR>", { desc = "Open tomorrow's note" })
		vim.keymap.set("n", "<Leader>oy", "<cmd>LspYesterday<CR>", { desc = "Open yesterday's note" })

		vim.api.nvim_create_user_command("Daily", function(args)
			local input = args.args

			client:exec_cmd({
				title = "Open daily note",
				command = "jump",
				arguments = { input },
			}, { bufnr = ev.buf })
		end, { desc = "Open daily note", nargs = "*" })
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

vim.keymap.set("n", "<Leader>L", "<cmd>Lazy<CR>", { desc = "Open Lazy" })
vim.keymap.set("n", "<Leader>S", "<cmd>Lazy sync<CR>", { desc = "Sync Lazy" })
vim.keymap.set("n", "<Leader>M", "<cmd>Mason<CR>", { desc = "Open Mason" })

vim.keymap.set("n", "<Leader>tf", function()
	vim.g.disable_autoformat = not vim.g.disable_autoformat
end, { desc = "Toggle format-on-save (Globally)" })

vim.keymap.set("n", "<Leader>tF", function()
	local bufnr = vim.fn.bufnr()
	vim.b[bufnr].disable_autoformat = not vim.b[bufnr].disable_autoformat
end, { desc = "Toggle format-on-save (Buffer)" })

--- local function run_long(name, cmds) -- Run a long-running command in a floating terminal. {{{
---
---@param name string
---@param cmds string[][]
local function run_long(name, cmds)
	local buf
	for _, id in ipairs(vim.api.nvim_list_bufs()) do
		if vim.api.nvim_buf_get_name(id) == "/" .. name then
			buf = id
			break
		end
	end
	if buf == nil then
		buf = vim.api.nvim_create_buf(true, false)
		vim.api.nvim_buf_set_name(buf, "/" .. name)
	end

	local window = vim.api.nvim_open_win(buf, false, {
		relative = "editor",
		width = 80,
		height = 15,
		row = vim.o.lines - 2,
		col = vim.o.columns,
		anchor = "SE",
		style = "minimal",
	})

	local chan = vim.api.nvim_open_term(buf, {})

	---@param data? string
	local function follow_append(data)
		if type(data) == "string" then
			vim.api.nvim_chan_send(chan, data)
			local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, true)
			if vim.api.nvim_win_is_valid(window) then
				vim.api.nvim_win_set_cursor(window, { #lines, 0 })
			end
		end
	end

	---@param idx number
	local function runit(idx)
		if cmds[idx] == nil then
			follow_append("\n-- Done --\n\n")
			vim.defer_fn(function()
				if vim.api.nvim_win_is_valid(window) then
					vim.api.nvim_win_close(window, false)
				end
			end, 3000)
			return
		end

		---@param err string
		---@param data string
		local echo = vim.schedule_wrap(function(err, data)
			follow_append(data)
			follow_append(err)
		end)

		vim.system(
			cmds[idx],
			{ stdout = echo, stderr = echo },
			---@param out vim.SystemCompleted
			vim.schedule_wrap(function(out)
				if out.code == 0 then
					runit(idx + 1)
				else
					if vim.api.nvim_win_is_valid(window) then
						follow_append("\n-- Completed with error --\n\n")
					end
				end
			end)
		)
	end

	runit(1)
end
-- }}}

-- For work

vim.keymap.set("n", "<Leader>dp", function()
	run_long("dev prepare", {
		{ "dev", "prepare" },
	})
end, { desc = "dev prepare" })
vim.keymap.set("n", "<Leader>dc", function()
	run_long("dev prepare && dev check", {
		{ "dev", "prepare" },
		{ "dev", "check" },
	})
end, { desc = "dev prepare && dev check" })
vim.keymap.set("n", "<Leader>do", function()
	run_long("dev check", {
		{ "dev", "check" },
	})
end, { desc = "dev check" })
vim.keymap.set("n", "<Leader>dq", function()
	run_long("bun-parallel", {
		{ "bun", "run", "--filter", "*", "check" },
		{ "bun", "run", "--filter", "stat.*", "lint" },
	})
end, { desc = "bun-parallel-check" })

-- }}}

-- Bootstrap lazy.nvim {{{
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
---@diagnostic disable-next-line: undefined-field
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
					fzf_opts = {
						["--cycle"] = true,
					},
					grep = {
						hidden = true,
					},
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
			---@diagnostic disable-next-line: undefined-doc-name
			---@type snacks.Config
			opts = {
				image = { enabled = true },
				input = { enabled = true },
				gh = {},
				picker = {
					sources = {
						gh_issue = {
							-- your gh_issue picker configuration comes here
							-- or leave it empty to use the default settings
						},
						gh_pr = {
							-- your gh_pr picker configuration comes here
							-- or leave it empty to use the default settings
						},
					},
				},
			},
			keys = {
				{
					"<leader>gi",
					function()
						Snacks.picker.gh_issue()
					end,
					desc = "GitHub Issues (open)",
				},
				{
					"<leader>gI",
					function()
						Snacks.picker.gh_issue({ state = "all" })
					end,
					desc = "GitHub Issues (all)",
				},
				{
					"<leader>gp",
					function()
						Snacks.picker.gh_pr()
					end,
					desc = "GitHub Pull Requests (open)",
				},
				{
					"<leader>gP",
					function()
						Snacks.picker.gh_pr({ state = "all" })
					end,
					desc = "GitHub Pull Requests (all)",
				},
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
						---@diagnostic disable-next-line: param-type-mismatch
						gitsigns.nav_hunk("next")
					end
				end)

				map("n", "[c", function()
					if vim.wo.diff then
						vim.cmd.normal({ "[c", bang = true })
					else
						---@diagnostic disable-next-line: param-type-mismatch
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
					---@diagnostic disable-next-line: param-type-mismatch
					gitsigns.diffthis("~")
				end)

				map("n", "<leader>hQ", function()
					---@diagnostic disable-next-line: param-type-mismatch
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

		-- WhoIsSethDaniel/mason-tool-installer.nvim {{{
		-- Install and upgrade third party tools automatically
		--
		-- And other LSP-related packages
		{
			"WhoIsSethDaniel/mason-tool-installer.nvim",
			opts = {},
			dependencies = {
				--  Portable package manager for Neovim that runs everywhere Neovim
				--  runs. Easily install and manage LSP servers, DAP servers, linters,
				--  and formatters.
				{ "mason-org/mason.nvim", opts = {} },
				--  Quickstart configs for Nvim LSP
				"neovim/nvim-lspconfig",
				--  Performant, batteries-included completion plugin for Neovim
				"saghen/blink.cmp",
				-- 💫 Extensible UI for Neovim notifications and LSP progress messages.
				{ "j-hui/fidget.nvim", opts = {} },
			},
			config = function()
				local capabilities = require("blink.cmp").get_lsp_capabilities()

				local lsp_list = {
					{ mason_name = "eslint-lsp", ls_config_name = "eslint", config = {} },
					{ mason_name = "json-lsp", ls_config_name = "jsonls", config = {} },
					{
						mason_name = "lua-language-server",
						ls_config_name = "lua_ls",
						config = {
							settings = {
								Lua = {
									completion = {
										callSnippet = "Replace",
									},
								},
							},
						},
					},
					{ mason_name = "markdown-oxide", ls_config_name = "markdown_oxide", config = {} },
					{ mason_name = "omnisharp", ls_config_name = "omnisharp", config = {} },
					{ mason_name = "prisma-language-server", ls_config_name = "prismals", config = {} },
					{
						mason_name = "rust-analyzer",
						ls_config_name = "rust_analyzer",
						config = {
							settings = {
								["rust-analyzer"] = {
									cargo = { features = "all" },
									check = { features = "all" },
								},
							},
						},
					},
					{
						mason_name = "solargraph",
						ls_config_name = "solargraph",
						config = {
							settings = {
								solargraph = {
									diagnostics = true,
								},
							},
						},
					},
					{ mason_name = "tailwindcss-language-server", ls_config_name = "tailwindcss", config = {} },
					{ mason_name = "taplo", ls_config_name = "taplo", config = {} },
					{
						mason_name = "typescript-language-server",
						ls_config_name = "ts_ls",
						config = {
							settings = {
								typescript = {
									inlayHints = {
										includeInlayParameterNameHints = "all",
										includeInlayParameterNameHintsWhenArgumentMatchesName = false,
										includeInlayVariableTypeHints = true,
										includeInlayFunctionParameterTypeHints = true,
										includeInlayVariableTypeHintsWhenTypeMatchesName = false,
										includeInlayPropertyDeclarationTypeHints = true,
										includeInlayFunctionLikeReturnTypeHints = true,
										includeInlayEnumMemberValueHints = true,
									},
								},
							},
						},
					},
				}

				---@param value string
				---@param list_of_tables {}
				local pluck = function(value, list_of_tables)
					local plucked = {}
					for i = 1, #list_of_tables do
						plucked[#plucked + 1] = list_of_tables[i][value]
					end
					return plucked
				end

				require("mason-tool-installer").setup({
					ensure_installed = {
						"prettier",
						"proselint",
						"shfmt",
						"stylua",
						"tree-sitter-cli",
						unpack(pluck("mason_name", lsp_list)),
					},
				})

				for i = 1, #lsp_list do
					local server = lsp_list[i]
					local server_config = server["config"]
					local server_name = server["ls_config_name"]
					server_config.capabilities =
						vim.tbl_deep_extend("force", {}, capabilities, server_config.capabilities or {})
					vim.lsp.config(server_name, server_config)
					vim.lsp.enable(server_name)
				end
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
				formatters = {
					prettier = {
						append_args = {
							"--plugin",
							vim.fn.expand(
								"$HOME/.bun/install/global/node_modules/prettier-plugin-organize-imports/index.js"
							),
						},
					},
					shfmt = {
						append_args = { "--case-indent", "--language-dialect", "bash" },
					},
				},
				formatters_by_ft = {
					bash = { "shfmt" },
					html = { "prettier" },
					javascript = { "prettier" },
					javascriptreact = { "prettier" },
					lua = { "stylua" },
					markdown = { "prettier" },
					rust = { "rustfmt", lsp_format = "fallback" },
					sh = { "shfmt" },
					shell = { "shfmt" },
					typescript = { "prettier" },
					typescriptreact = { "prettier" },
					yaml = { "prettier" },
					zsh = { "shfmt" },
				},
				format_on_save = function(bufnr)
					-- Disable with a global or buffer-local variable
					if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then
						return
					end

					return {
						timeout_ms = 500,
						lsp_format = "fallback",
					}
				end,
			},
		},
		-- }}}

		-- mfussenegger/nvim-lint {{{
		-- An asynchronous linter plugin for Neovim complementary to the built-in Language Server Protocol support.
		{
			"mfussenegger/nvim-lint",
			config = function()
				local lint = require("lint")
				lint.linters_by_ft = {
					markdown = { "proselint" },
				}

				local lint_augroup = vim.api.nvim_create_augroup("lint", { clear = true })

				vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave" }, {
					group = lint_augroup,
					callback = function()
						lint.try_lint()
					end,
				})
			end,
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
