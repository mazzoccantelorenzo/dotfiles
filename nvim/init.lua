-- Set leader keys
vim.g.mapleader = " "
vim.g.maplocalleader = " "
vim.opt.tabstop = 4      -- Numero di spazi che un tab "vale" visivamente
vim.opt.softtabstop = 4  -- Numero di spazi inseriti quando premi Tab
vim.opt.shiftwidth = 4   -- Numero di spazi per l'auto-indentazione (es. dopo una graff
-- Configure diagnostics
vim.diagnostic.config({
	virtual_text = true,
	signs = true,
	float = { border = "rounded" },
})
-- Sync with system clipboard
vim.opt.clipboard = "unnamedplus"

-- disable netrw completely to avoid nvim-tree conflicts
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- setup termguicolors to enable highlight groups
vim.opt.termguicolors = true

vim.keymap.set('n', '<leader>e', ':NvimTreeToggle<CR>', { noremap = true, silent = true })
-- Diagnostic keymaps
vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, { desc = 'Show Error' })
-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		"--branch=stable",
		lazypath,
	})
end
vim.opt.rtp:prepend(lazypath)

-- Setup plugins
require("lazy").setup({
	{
    "hrsh7th/nvim-cmp",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp", -- Engine for LSP completions
      "L3MON4D3/LuaSnip",     -- Snippet engine
      "saadparwaiz1/cmp_luasnip",
    },
    config = function()
      local cmp = require("cmp")
      cmp.setup({
        snippet = {
          expand = function(args)
            require("luasnip").lsp_expand(args.body)
          end,
        },
        mapping = cmp.mapping.preset.insert({
          ["<C-b>"] = cmp.mapping.scroll_docs(-4),
          ["<C-f>"] = cmp.mapping.scroll_docs(4),
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<CR>"] = cmp.mapping.confirm({ select = true }),
          ["<Tab>"] = cmp.mapping.select_next_item(),
          ["<S-Tab>"] = cmp.mapping.select_prev_item(),
        }),
        sources = cmp.config.sources({
          { name = "nvim_lsp" },
          { name = "luasnip" },
        }),
      })
    end,
  },
	{
		"nvim-treesitter/nvim-treesitter",
		build = ":TSUpdate",
		config = function()
			require("nvim-treesitter.configs").setup({
				ensure_installed = { "c", "cpp", "make", "bash" },
				highlight = { enable = true },
			})
		end
	},
	{
  "stevearc/conform.nvim",
  event = { "BufWritePre" }, -- Si attiva poco prima di scrivere il file
  opts = {
    formatters_by_ft = {
      c = { "clang-format" },
      cpp = { "clang-format" },
      -- Per l'ASM meglio non metterne uno automatico o nvim-tree si rompe
    },
    -- QUESTA È LA PARTE CHE TI SERVE:
    format_on_save = {
      timeout_ms = 500,     -- Se ci mette più di mezzo secondo, lascia stare
      lsp_fallback = true,   -- Se non trova clang-format, usa l'LSP (clangd)
    },
  },
},

	-- lsp package manager
	{ "williamboman/mason.nvim", config = true },

	-- bridge between mason and lspconfig
	{
		"williamboman/mason-lspconfig.nvim",
		config = function()
			require("mason-lspconfig").setup({
				ensure_installed = { "clangd", "asm_lsp" }
			})
		end
	},

	-- core lsp configuration
	{
		"neovim/nvim-lspconfig",
		config = function()
			local lspconfig = require("lspconfig")

			-- enable C lsp
			lspconfig.clangd.setup({})
			-- enable ASM lsp
			lspconfig.asm_lsp.setup({})
		end
	},
	{
		"nvim-tree/nvim-tree.lua",
		version = "*",
		lazy = false,
		dependencies = {
			"nvim-tree/nvim-web-devicons",
		},
		config = function()
			require("nvim-tree").setup {}
		end,
	},
	{
		"tpope/vim-fugitive",
		config = function()
			-- Fugitive basic keymaps
			vim.keymap.set("n", "<leader>gs", vim.cmd.Git, { desc = "Git Status" })
		end
	},
	-- Telescope
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
				defaults = { layout_config = { horizontal = { border = "rounded" } } },
			})
			pcall(telescope.load_extension, 'fzf')

			local builtin = require('telescope.builtin')
			vim.keymap.set('n', '<leader>ff', builtin.find_files, { desc = 'Find Files' })
			vim.keymap.set('n', '<leader>fg', builtin.live_grep, { desc = 'Live Grep' })
			vim.keymap.set('n', '<leader>fb', builtin.buffers, { desc = 'Buffers' })
		end
	},

	-- Treesitter
	{
		'nvim-treesitter/nvim-treesitter',
		build = ':TSUpdate',
		main = 'nvim-treesitter.configs',
		opts = {
			ensure_installed = { 'bash', 'c', 'lua', 'vim', 'vimdoc', 'go', 'typescript', 'tsx', 'javascript', 'html' },
			auto_install = true,
			highlight = { enable = true },
			indent = { enable = true },
		},
	},

	-- LSP & Mason
	{
		"neovim/nvim-lspconfig",
		dependencies = {
			"williamboman/mason.nvim",
			"williamboman/mason-lspconfig.nvim",
		},
		config = function()
			require("mason").setup()
			require("mason-lspconfig").setup({
				ensure_installed = { "vtsls", "gopls" },
			})

			-- Nvim 0.11 native LSP
			vim.lsp.enable("vtsls")
			vim.lsp.enable("gopls")

			-- LSP keymaps
			vim.keymap.set('n', 'gd', vim.lsp.buf.definition, {})
			vim.keymap.set('n', 'K', vim.lsp.buf.hover, {})
		end,
	},
	-- Oil
	{
		'stevearc/oil.nvim',
		dependencies = { "nvim-tree/nvim-web-devicons" },
		config = function()
			require("oil").setup()
			vim.keymap.set("n", "-", "<CMD>Oil<CR>", { desc = "Open parent directory" })
		end
	},
	{
		"folke/todo-comments.nvim",
		dependencies = { "nvim-lua/plenary.nvim" },
		config = function()
			require("todo-comments").setup({})
			-- Explicit keymap
			vim.keymap.set("n", "<leader>ft", "<cmd>TodoTelescope<cr>", { desc = "Find TODOs" })
		end
	},
	{
		'lewis6991/gitsigns.nvim',
		opts = {
			-- Enable inline git blame by default
			current_line_blame = true,

			on_attach = function(bufnr)
				local gs = package.loaded.gitsigns

				local function map(mode, l, r, opts)
					opts = opts or {}
					opts.buffer = bufnr
					vim.keymap.set(mode, l, r, opts)
				end

				-- Navigation
				map('n', ']c', function()
					if vim.wo.diff then return ']c' end
					vim.schedule(function() gs.next_hunk() end)
					return '<Ignore>'
				end, {expr=true, desc='Next git hunk'})

				map('n', '[c', function()
					if vim.wo.diff then return '[c' end
					vim.schedule(function() gs.prev_hunk() end)
					return '<Ignore>'
				end, {expr=true, desc='Prev git hunk'})

				-- Actions
				map('n', '<leader>hp', gs.preview_hunk, { desc = 'Preview git diff' })
				map('n', '<leader>hb', function() gs.blame_line{full=true} end, { desc = 'Detailed git blame' })
				map('n', '<leader>tb', gs.toggle_current_line_blame, { desc = 'Toggle inline blame' })
			end
		}
	},
})
