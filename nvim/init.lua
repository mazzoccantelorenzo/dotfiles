-- ========================================================================== --
--                             UTILITY FUNCTIONS                              --
-- ========================================================================== --
local function nmap(comb, cmd, desc)
    vim.api.nvim_set_keymap('n', comb, cmd, { noremap = true, silent = true, desc = desc })
end

-- ========================================================================== --
--                              EDITOR OPTIONS                                --
-- ========================================================================== --
vim.g.mapleader = " "
vim.g.maplocalleader = " "

vim.opt.tabstop = 4               -- Visual spaces per tab
vim.opt.softtabstop = 4           -- Inserted spaces per tab
vim.opt.shiftwidth = 4            -- Auto-indent spaces
vim.opt.clipboard = "unnamedplus" -- Sync with system clipboard
vim.opt.termguicolors = true      -- Enable 24-bit RGB colors
vim.opt.number = true             -- Show line numbers
vim.opt.showtabline = 2           -- Always show tabline
vim.g.loaded_netrw = 1            -- Disable netrw
vim.g.loaded_netrwPlugin = 1

-- Diagnostics styling
vim.diagnostic.config({
    virtual_text = true,
    signs = true,
    float = { border = "rounded" },
})

-- ========================================================================== --
--                                KEYBINDINGS                                 --
-- ========================================================================== --
-- Navigation
vim.keymap.set('n', 'q', 'b', { noremap = true, desc = "Move back a word" })
vim.keymap.set({'n', 'i', 'v'}, '<C-e>', function()
    if vim.api.nvim_get_mode().mode == 'i' then
        vim.cmd('normal! $')
        vim.cmd('startinsert!')
    else
        vim.cmd('normal! $')
    end
end, { desc = "End of line" })

-- Tabs/Workspaces
vim.keymap.set("n", "<leader>tn", "<cmd>tabnew<CR>", { desc = "New Tab" })
vim.keymap.set("n", "<leader>tc", "<cmd>tabclose<CR>", { desc = "Close Tab" })
vim.keymap.set("n", "<S-tab>", "<cmd>tabnext<CR>", { desc = "Next Tab" })
vim.keymap.set("n", "<S-h>", "<cmd>tabprevious<CR>", { desc = "Previous Tab" })

-- File Explorer & Search
vim.keymap.set('n', '<leader>e', ':NvimTreeToggle<CR>', { silent = true, desc = "Toggle Tree" })
nmap('<leader>p', ':lua require"telescope.builtin".commands() <CR>', "Search commands")

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
--                               PLUGINS SETUP                                --
-- ========================================================================== --
require("lazy").setup({
    -- UI & Themes
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
    { "rose-pine/neovim", name = "rose-pine" },
    {
        "akinsho/bufferline.nvim",
        version = "*",
        dependencies = "nvim-tree/nvim-web-devicons",
        config = function()
            require("bufferline").setup({
                options = {
                    mode = "tabs",
                    separator_style = "thin",
                    show_buffer_close_icons = false,
                    show_close_icon = false,
                },
            })
        end,
    },

    -- Navigation & Search
    {
        'nvim-telescope/telescope.nvim',
        dependencies = { 'nvim-lua/plenary.nvim', { 'nvim-telescope/telescope-fzf-native.nvim', build = 'make' } },
        config = function()
            local telescope = require('telescope')
            local builtin = require('telescope.builtin')
            telescope.setup({ defaults = { layout_config = { horizontal = { border = "rounded" } } } })
            pcall(telescope.load_extension, 'fzf')

            vim.keymap.set('n', '<leader>ff', builtin.find_files, { desc = 'Find Files' })
            vim.keymap.set('n', '<leader>fg', builtin.live_grep, { desc = 'Live Grep' })
            vim.keymap.set('n', '<leader>fW', function()
                builtin.live_grep({ additional_args = function() return { "-F" } end })
            end, { desc = 'Live Grep (Literal)' })
            vim.keymap.set('n', '<leader>fc', function() builtin.colorscheme({ enable_preview = true }) end, { desc = 'Colorscheme Preview' })
        end
    },
    { "folke/trouble.nvim", opts = {}, cmd = "Trouble", keys = { { "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>", desc = "Diagnostics" } } },
    { "sindrets/diffview.nvim", dependencies = { "nvim-tree/nvim-web-devicons" } },
    { "tiagovla/scope.nvim", config = function() require("scope").setup({}) end },
    {
        "stevearc/conform.nvim",
        keys = { { "<leader>f", function() require("conform").format({ async = true, lsp_format = "fallback" }) end, desc = "Format buffer" } },
        opts = {
            formatters_by_ft = { javascript = { "prettier" }, typescript = { "prettier" }, json = { "prettier" }, html = { "prettier" }, css = { "prettier" } },
            format_on_save = { timeout_ms = 5000, lsp_format = "fallback" },
        },
    },
    { "folke/flash.nvim", event = "VeryLazy", opts = {}, keys = { { "s", mode = { "n", "x", "o" }, function() require("flash").jump() end, desc = "Flash" } } },

    -- File Explorer
    {
        "nvim-tree/nvim-tree.lua",
        config = function()
            require("nvim-tree").setup({ view = { width = 30 }, filters = { git_ignored = false } })
            vim.keymap.set("n", "<C-n>", "<cmd>NvimTreeToggle<CR>", { desc = "Toggle Tree" })
        end,
    },
    { 'stevearc/oil.nvim', config = function() require("oil").setup(); vim.keymap.set("n", "-", "<CMD>Oil<CR>") end },

    -- LSP & Coding
    {
        "neovim/nvim-lspconfig",
        dependencies = { "williamboman/mason.nvim", "williamboman/mason-lspconfig.nvim", "hrsh7th/cmp-nvim-lsp" },
        config = function()
            require("mason").setup({ ui = { border = "rounded" } })
            require("mason-lspconfig").setup({ ensure_installed = { "clangd", "vtsls", "gopls", "lua_ls" } })
            local lspconfig = require("lspconfig")
            local capabilities = require('cmp_nvim_lsp').default_capabilities()
            local on_attach = function(_, bufnr)
                local opts = { buffer = bufnr }
                vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
                vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
                vim.keymap.set("n", "<leader>vrn", vim.lsp.buf.rename, opts)
            end
            local servers = { "clangd", "vtsls", "gopls", "lua_ls" }
            for _, lsp in ipairs(servers) do
                lspconfig[lsp].setup({ on_attach = on_attach, capabilities = capabilities })
            end
        end,
    },
    {
        "hrsh7th/nvim-cmp",
        dependencies = { "L3MON4D3/LuaSnip", "saadparwaiz1/cmp_luasnip" },
        config = function()
            local cmp = require("cmp")
            cmp.setup({
                snippet = { expand = function(args) require("luasnip").lsp_expand(args.body) end },
                mapping = cmp.mapping.preset.insert({ ["<CR>"] = cmp.mapping.confirm({ select = true }) }),
                sources = { { name = "nvim_lsp" }, { name = "luasnip" } },
            })
        end,
    },
    {
        'nvim-treesitter/nvim-treesitter',
        build = ':TSUpdate',
        config = function()
            local status, configs = pcall(require, "nvim-treesitter.configs")
            if not status then
                configs = require("nvim-treesitter")
            end
            configs.setup({
                ensure_installed = { 'lua', 'go', 'typescript', 'javascript', 'html', 'bash' },
                highlight = { enable = true },
                indent = { enable = true },
            })
        end
    },

    -- Git
    { "lewis6991/gitsigns.nvim", opts = { current_line_blame = true } },
    { "kdheepak/lazygit.nvim", keys = { { "<leader>lg", "<cmd>LazyGit<cr>" } } },

    -- Utils
    { "folke/which-key.nvim", event = "VeryLazy", opts = {} },
    { "max397574/better-escape.nvim", config = function() require("better_escape").setup() end },
})

-- ========================================================================== --
--                                AUTOCOMMANDS                                --
-- ========================================================================== --
-- Format on save for Go/TS/JS
vim.api.nvim_create_autocmd("BufWritePre", {
    pattern = { "*.go", "*.ts", "*.tsx", "*.js", "*.jsx" },
    callback = function()
        vim.lsp.buf.format({ async = false })
    end,
})
