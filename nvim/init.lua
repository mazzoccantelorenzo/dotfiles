-- Leader keys
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Editor options
vim.opt.tabstop = 4      -- Visual spaces per tab
vim.opt.softtabstop = 4  -- Spaces inserted per tab
vim.opt.shiftwidth = 4   -- Auto-indent spaces
vim.opt.clipboard = "unnamedplus" -- Sync system clipboard
vim.opt.termguicolors = true

-- Diagnostics config
vim.diagnostic.config({
    virtual_text = true,
    signs = true,
    float = { border = "rounded" },
})

-- Disable netrw (prevents nvim-tree conflicts)
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- Global keymaps
vim.keymap.set('n', '<leader>e', ':NvimTreeToggle<CR>', { noremap = true, silent = true })
vim.keymap.set('n', '<leader>d', vim.diagnostic.open_float, { desc = 'Show Error' })

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
    -- Icons
    { "nvim-tree/nvim-web-devicons", lazy = true },
          {
              "stevearc/conform.nvim",
              event = { "BufWritePre" },
              opts = {
                  formatters_by_ft = {
                      c = { "clang-format" },
                      cpp = { "clang-format" },
                      -- Web Dev
                      javascript = { "prettierd", "prettier", stop_after_first = true },
                      typescript = { "prettierd", "prettier", stop_after_first = true },
                      javascriptreact = { "prettierd", "prettier", stop_after_first = true },
                      typescriptreact = { "prettierd", "prettier", stop_after_first = true },
                      json = { "prettierd", "prettier", stop_after_first = true },
                      html = { "prettierd", "prettier", stop_after_first = true },
                      css = { "prettierd", "prettier", stop_after_first = true },
                  },
                  format_on_save = {
                      timeout_ms = 500,
                      lsp_fallback = true,
                  },
              },
          },
    -- Themes
    {
        "catppuccin/nvim",
        name = "catppuccin",
        priority = 1000,
        config = function()
            require("catppuccin").setup({
                flavour = "mocha",
                transparent_background = false,
                term_colors = true,
                integrations = {
                    cmp = true,
                    gitsigns = true,
                    nvimtree = true,
                    treesitter = true,
                    notify = true,
                    mini = { enabled = true, indentscope_color = "" },
                },
            })
            vim.cmd.colorscheme("catppuccin")
        end,
    },
    { "folke/tokyonight.nvim" },
    { "rose-pine/neovim", name = "rose-pine" },
    { "ellisonleao/gruvbox.nvim" },
    { "EdenEast/nightfox.nvim" },
    { "rebelot/kanagawa.nvim" },

    -- CMP (Autocompletion)
    {
        "hrsh7th/nvim-cmp",
        dependencies = {
            "hrsh7th/cmp-nvim-lsp",
            "L3MON4D3/LuaSnip",
            "saadparwaiz1/cmp_luasnip",
        },
        config = function()
            local cmp = require("cmp")
            local luasnip = require("luasnip")

            cmp.setup({
                snippet = {
                    expand = function(args) luasnip.lsp_expand(args.body) end,
                },
                mapping = cmp.mapping.preset.insert({
                    ["<C-b>"] = cmp.mapping.scroll_docs(-4),
                    ["<C-f>"] = cmp.mapping.scroll_docs(4),
                    ["<C-Space>"] = cmp.mapping.complete(),
                    ["<CR>"] = cmp.mapping.confirm({ select = true }),
                    ["<Tab>"] = cmp.mapping(function(fallback)
                        if cmp.visible() then cmp.select_next_item()
                        elseif luasnip.expand_or_jumpable() then luasnip.expand_or_jump()
                        else fallback() end
                    end, { "i", "s" }),
                    ["<S-Tab>"] = cmp.mapping(function(fallback)
                        if cmp.visible() then cmp.select_prev_item()
                        elseif luasnip.jumpable(-1) then luasnip.jump(-1)
                        else fallback() end
                    end, { "i", "s" }),
                }),
                sources = cmp.config.sources({
                    { name = "nvim_lsp" },
                    { name = "luasnip" },
                }),
            })
        end,
    },

    -- Treesitter
    {
        'nvim-treesitter/nvim-treesitter',
        build = ':TSUpdate',
        config = function()
            require("nvim-treesitter.configs").setup({
                ensure_installed = { 'bash', 'c', 'lua', 'vim', 'go', 'typescript', 'tsx', 'javascript', 'html' },
                auto_install = true,
                highlight = { enable = true },
                indent = { enable = true },
            })
        end,
    },

    -- Formatting
    {
        "stevearc/conform.nvim",
        event = { "BufWritePre" },
        opts = {
            formatters_by_ft = {
                c = { "clang-format" },
                cpp = { "clang-format" },
            },
            format_on_save = {
                timeout_ms = 500,
                lsp_fallback = true,
            },
        },
    },

    -- LSP & Mason (JS/TS, Go, Lua)
    {
        "neovim/nvim-lspconfig",
        dependencies = {
            "williamboman/mason.nvim",
            "williamboman/mason-lspconfig.nvim",
        },
        config = function()
            require("mason").setup({ ui = { border = "rounded" } })
            require("mason-lspconfig").setup({
                ensure_installed = { "clangd", "asm_lsp", "vtsls", "eslint", "gopls", "lua_ls" }
            })

            local lspconfig = require("lspconfig")
            local capabilities = vim.lsp.protocol.make_client_capabilities()

            -- LSP keymaps
            local on_attach = function(_, bufnr)
                local opts = { buffer = bufnr, remap = false }
                vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
                vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
                vim.keymap.set("n", "<leader>vws", vim.lsp.buf.workspace_symbol, opts)
                vim.keymap.set("n", "<leader>vd", vim.diagnostic.open_float, opts)
                vim.keymap.set("n", "[d", vim.diagnostic.goto_next, opts)
                vim.keymap.set("n", "]d", vim.diagnostic.goto_prev, opts)
                vim.keymap.set("n", "<leader>vca", vim.lsp.buf.code_action, opts)
                vim.keymap.set("n", "<leader>vrr", vim.lsp.buf.references, opts)
                vim.keymap.set("n", "<leader>vrn", vim.lsp.buf.rename, opts)
                vim.keymap.set("i", "<C-h>", vim.lsp.buf.signature_help, opts)
            end

            -- Server setups
            local servers = { "clangd", "asm_lsp", "vtsls", "eslint", "gopls" }
            for _, lsp in ipairs(servers) do
                lspconfig[lsp].setup({
                    on_attach = on_attach,
                    capabilities = capabilities,
                })
            end

            -- Lua specific setup
            lspconfig.lua_ls.setup({
                on_attach = on_attach,
                capabilities = capabilities,
                settings = {
                    Lua = { diagnostics = { globals = { 'vim' } } }
                }
            })
            -- Configure vtsls for TS/JS and React (TSX/JSX)
            lspconfig.vtsls.setup({
                on_attach = on_attach,
                capabilities = capabilities,
                filetypes = {
                    "javascript",
                    "javascriptreact",
                    "javascript.jsx",
                    "typescript",
                    "typescriptreact",
                    "typescript.tsx"
                },
                -- Enable diagnostics even without package.json/tsconfig.json
                single_file_support = true,
            })
            -- Formatting
    
        end,
    },

    -- Nvim Tree
    {
        "nvim-tree/nvim-tree.lua",
        dependencies = { "nvim-tree/nvim-web-devicons" },
        config = function()
            require("nvim-tree").setup({ view = { width = 30, side = "left" } })
            vim.keymap.set("n", "<C-n>", "<cmd>NvimTreeToggle<CR>", { desc = "Toggle NvimTree" })
        end,
    },

    -- Git tools (Fugitive & Lazygit)
    {
        "tpope/vim-fugitive",
        config = function()
            vim.keymap.set("n", "<leader>gs", vim.cmd.Git, { desc = "Git Status" })
        end
    },
    {
        "kdheepak/lazygit.nvim",
        cmd = {
            "LazyGit",
            "LazyGitConfig",
            "LazyGitCurrentFile",
            "LazyGitFilter",
            "LazyGitFilterCurrentFile",
        },
        dependencies = {
            "nvim-lua/plenary.nvim",
        },
        keys = {
            { "<leader>lg", "<cmd>LazyGit<cr>", desc = "Open LazyGit" },
        },
    },

    -- Gitsigns
    {
        'lewis6991/gitsigns.nvim',
        opts = {
            current_line_blame = true,
            on_attach = function(bufnr)
                local gs = package.loaded.gitsigns
                local function map(mode, l, r, opts)
                    opts = opts or {}
                    opts.buffer = bufnr
                    vim.keymap.set(mode, l, r, opts)
                end

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

                map('n', '<leader>hp', gs.preview_hunk, { desc = 'Preview git diff' })
                map('n', '<leader>hb', function() gs.blame_line{full=true} end, { desc = 'Detailed git blame' })
                map('n', '<leader>tb', gs.toggle_current_line_blame, { desc = 'Toggle inline blame' })
            end
        }
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
                defaults = {
                    layout_config = { horizontal = { border = "rounded" } },
                    file_ignore_patterns = { "node_modules", ".git/", "dist/", "build/", "target/", "%.lock" },
                    vimgrep_arguments = {
                        'rg', '--color=never', '--no-heading', '--with-filename',
                        '--line-number', '--column', '--smart-case', '--hidden',
                    },
                },
                pickers = {
                    find_files = {
                        hidden = true,
                        find_command = { "rg", "--files", "--hidden", "--ignore-case", "--glob", "!**/.git/*" },
                    },
                    live_grep = {
                        additional_args = function() return { "--ignore-case" } end
                    },
                }
            })
            pcall(telescope.load_extension, 'fzf')

            local builtin = require('telescope.builtin')
            vim.keymap.set('n', '<leader>ff', builtin.find_files, { desc = 'Find Files' })
            vim.keymap.set('n', '<leader>fg', builtin.live_grep, { desc = 'Live Grep' })
            vim.keymap.set('n', '<leader>fb', builtin.buffers, { desc = 'Buffers' })
        end
    },

    -- Oil
    {
        'stevearc/oil.nvim',
        dependencies = { "nvim-tree/nvim-web-devicons" },
        config = function()
            require("oil").setup()
            vim.keymap.set("n", "-", "<CMD>Oil<CR>", { desc = "Open parent dir" })
        end
    },

    -- TODO Comments
    {
        "folke/todo-comments.nvim",
        dependencies = { "nvim-lua/plenary.nvim" },
        config = function()
            require("todo-comments").setup({})
            vim.keymap.set("n", "<leader>ft", "<cmd>TodoTelescope<cr>", { desc = "Find TODOs" })
        end
    },
})