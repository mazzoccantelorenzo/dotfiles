-- Set leader keys
vim.g.mapleader = " "
vim.g.maplocalleader = " "
-- Configure diagnostics
vim.diagnostic.config({
  virtual_text = true,
  signs = true,
  float = { border = "rounded" },
})
-- Sync with system clipboard
vim.opt.clipboard = "unnamedplus"

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
