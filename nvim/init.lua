-- ========================================================================== --
--                               LEADER KEYS                                  --
-- ========================================================================== --
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- ========================================================================== --
--                              EDITOR OPTIONS                                --
-- ========================================================================== --
vim.opt.tabstop = 4               -- Spazi visivi per tab
vim.opt.softtabstop = 4           -- Spazi inseriti per tab
vim.opt.shiftwidth = 4            -- Spazi auto-indent
vim.opt.clipboard = "unnamedplus" -- Sincronizza clipboard di sistema
vim.opt.termguicolors = true
vim.opt.number = true             -- Numeri di riga assoluti

-- Disabilita netrw per nvim-tree
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- Configurazione diagnostica
vim.diagnostic.config({
	virtual_text = true,
	signs = true,
	float = { border = "rounded" },
})

-- ========================================================================== --
--                             GLOBAL KEYMAPS                                 --
-- ========================================================================== --
vim.keymap.set('n', '<leader>e', ':NvimTreeToggle<CR>', { noremap = true, silent = true })
vim.keymap.set('n', '<leader>d', vim.diagnostic.open_float, { desc = 'Show Error' })

-- ========================================================================== --
--                             BOOTSTRAP LAZY.NVIM                            --
-- ========================================================================== --
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
	vim.fn.system({
		"git", "clone", "--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git", "--branch=stable", lazypath,
	})
end
vim.opt.rtp:prepend(lazypath)

-- ========================================================================== --
--                                AUTOCOMMANDS                                --
-- ========================================================================== --
-- Go: Organize imports and format on save
vim.api.nvim_create_autocmd("BufWritePre", {
	pattern = "*.go",
	callback = function()
		local params = vim.lsp.util.make_range_params()
		params.context = { only = { "source.organizeImports" } }
		local result = vim.lsp.buf_request_sync(0, "textDocument/codeAction", params)
		for _, res in pairs(result or {}) do
			for _, r in pairs(res.result or {}) do
				if r.edit then
					vim.lsp.util.apply_workspace_edit(r.edit, "utf-8")
				else
					vim.lsp.buf.execute_command(r.command)
				end
			end
		end
		vim.lsp.buf.format({ async = false })
	end,
})

-- ========================================================================== --
--                               PLUGINS SETUP                                --
-- ========================================================================== --
require("lazy").setup({
	-- TELESCOPE
	{
		'nvim-telescope/telescope.nvim',
		version = '*',
		dependencies = {
			'nvim-lua/plenary.nvim',
			{ 'nvim-telescope/telescope-fzf-native.nvim', build = 'make' },
		},
		config = function()
			local telescope = require('telescope')
			telescope.setup({
				defaults = {
					layout_config = { horizontal = { border = "rounded" } },
					file_ignore_patterns = { "node_modules", ".git/", "dist/" },
				},
			})
			pcall(telescope.load_extension, 'fzf')

			local builtin = require('telescope.builtin')
			vim.keymap.set('n', '<leader>ff', builtin.find_files, { desc = 'Find Files' })
			vim.keymap.set('n', '<leader>fg', builtin.live_grep, { desc = 'Live Grep' })
			vim.keymap.set('n', '<leader>fb', builtin.buffers, { desc = 'Buffers' })
		end
	},

	-- UI: Noice & Notifications
	{
		"folke/noice.nvim",
		event = "VeryLazy",
		opts = {
			presets = {
				bottom_search = true,
				command_palette = true,
				long_message_to_split = true,
			},
		},
		dependencies = { "MunifTanjim/nui.nvim", "rcarriga/nvim-notify" }
	},

	-- ICONS
	{ "nvim-tree/nvim-web-devicons", lazy = true },

	-- FILE EXPLORER
	{
		"nvim-tree/nvim-tree.lua",
		config = function()
			require("nvim-tree").setup({ view = { width = 30, side = "left" } })
			vim.keymap.set("n", "<C-n>", "<cmd>NvimTreeToggle<CR>", { desc = "Toggle NvimTree" })
		end,
	},
	{
		"mazzoccantelorenzo/ghostty-fonts.nvim",
		cmd = { "GhosttyFonts", "FontFamily", "FontSize" },
		config = function()
			require("ghostty-fonts").setup()
		end,
	},
	{
		'stevearc/oil.nvim',
		config = function()
			require("oil").setup()
			vim.keymap.set("n", "-", "<CMD>Oil<CR>", { desc = "Open parent dir" })
		end
	},

	-- FORMATTING: Conform
	{
		"stevearc/conform.nvim",
		event = { "BufWritePre" },
		opts = {
			formatters_by_ft = {
				c = { "clang-format" },
				cpp = { "clang-format" },
				javascript = { "prettierd", "prettier", stop_after_first = true },
				typescript = { "prettierd", "prettier", stop_after_first = true },
				json = { "prettierd", "prettier", stop_after_first = true },
				html = { "prettierd", "prettier", stop_after_first = true },
				css = { "prettierd", "prettier", stop_after_first = true },
			},
			format_on_save = { timeout_ms = 5000, lsp_fallback = true },
		},
	},

	-- THEMES
	{
		"catppuccin/nvim",
		name = "catppuccin",
		priority = 1000,
		config = function()
			require("catppuccin").setup({ flavour = "mocha", integrations = { notify = true, nvimtree = true, cmp = true } })
			vim.cmd.colorscheme("catppuccin")
		end,
	},
	{ "folke/tokyonight.nvim" },
	{ "rebelot/kanagawa.nvim" },

	-- LSP: Mason & LspConfig
	{
		"neovim/nvim-lspconfig",
		dependencies = {
			"williamboman/mason.nvim",
			"williamboman/mason-lspconfig.nvim",
			"hrsh7th/cmp-nvim-lsp",
		},
		config = function()
			require("mason").setup({ ui = { border = "rounded" } })
			require("mason-lspconfig").setup({
				ensure_installed = { "clangd", "asm_lsp", "vtsls", "eslint", "gopls", "lua_ls" }
			})

			local lspconfig = require("lspconfig")
			local capabilities = require('cmp_nvim_lsp').default_capabilities()

			local on_attach = function(_, bufnr)
				local opts = { buffer = bufnr }
				vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
				vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
				vim.keymap.set("n", "<leader>vca", vim.lsp.buf.code_action, opts)
				vim.keymap.set("n", "<leader>vrn", vim.lsp.buf.rename, opts)
				vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
			end

			local servers = { "clangd", "asm_lsp", "vtsls", "eslint", "gopls", "lua_ls" }
			for _, lsp in ipairs(servers) do
				local config = { on_attach = on_attach, capabilities = capabilities }
				if lsp == "lua_ls" then
					config.settings = { Lua = { diagnostics = { globals = { 'vim' } } } }
				end
				lspconfig[lsp].setup(config)
			end
		end,
	},

	-- AUTOCOMPLETE: CMP
	{
		"hrsh7th/nvim-cmp",
		dependencies = { "L3MON4D3/LuaSnip", "saadparwaiz1/cmp_luasnip" },
		config = function()
			local cmp = require("cmp")
			local luasnip = require("luasnip")
			cmp.setup({
				snippet = { expand = function(args) luasnip.lsp_expand(args.body) end },
				mapping = cmp.mapping.preset.insert({
					["<CR>"] = cmp.mapping.confirm({ select = true }),
					["<Tab>"] = cmp.mapping(function(fallback)
						if cmp.visible() then
							cmp.select_next_item()
						elseif luasnip.expand_or_jumpable() then
							luasnip.expand_or_jump()
						else
							fallback()
						end
					end, { "i", "s" }),
				}),
				sources = { { name = "nvim_lsp" }, { name = "luasnip" } },
			})
		end,
	},

	-- TREESITTER: Configurazione corretta per Neovim 0.11/0.12
	{
		'nvim-treesitter/nvim-treesitter',
		build = ':TSUpdate',
		config = function()
			-- Usiamo il nuovo modo di caricare treesitter
			local configs = require("nvim-treesitter")

			-- Se il comando sopra fallisce, prova questo fallback
			local status, ts_configs = pcall(require, "nvim-treesitter.configs")
			local setup_target = status and ts_configs or configs

			setup_target.setup({
				ensure_installed = { 'bash', 'c', 'lua', 'go', 'typescript', 'javascript', 'html' },
				highlight = { enable = true },
				indent = { enable = true },
			})
		end,
	},

	-- GIT
	{ "lewis6991/gitsigns.nvim", opts = { current_line_blame = true } },
	{ "tpope/vim-fugitive" },
	{
		"kdheepak/lazygit.nvim",
		dependencies = { "nvim-lua/plenary.nvim" },
		keys = { { "<leader>lg", "<cmd>LazyGit<cr>", desc = "Open LazyGit" } },
	},

	-- UTILS
	{ "folke/todo-comments.nvim", dependencies = { "nvim-lua/plenary.nvim" }, opts = {} },
})
