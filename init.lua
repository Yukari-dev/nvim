-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
    vim.fn.system({"git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git", lazypath})
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
    { "blazkowolf/gruber-darker.nvim" },
    { "rebelot/kanagawa.nvim" },
    { "folke/tokyonight.nvim" },
    { "rose-pine/neovim", name = "rose-pine" },
    { "nyoom-engineering/oxocarbon.nvim" },

    { "lewis6991/gitsigns.nvim",
        config = function()
            require("gitsigns").setup({
                signs = {
                    add          = { text = "│" },
                    change       = { text = "│" },
                    delete       = { text = "−" },
                    topdelete    = { text = "−" },
                    changedelete = { text = "~" },
                },
            })
        end,
    },
    { "echasnovski/mini.pairs", version = "*",
        config = function()
            require("mini.pairs").setup()
        end,
    },
    { "lukas-reineke/indent-blankline.nvim", main = "ibl",
        config = function()
            require("ibl").setup({
                indent = { char = "▏" },
                scope = { enabled = false },
            })
        end,
    },
    { "folke/todo-comments.nvim", dependencies = { "nvim-lua/plenary.nvim" },
        config = function()
            require("todo-comments").setup()
        end,
    },
    { "nvim-telescope/telescope.nvim", dependencies = { "nvim-lua/plenary.nvim" },
        config = function()
            local tel = require("telescope.builtin")
            vim.keymap.set("n", "<leader>ff", tel.find_files)
            vim.keymap.set("n", "<leader>fg", tel.live_grep)
            vim.keymap.set("n", "<leader>fb", tel.buffers)
            vim.keymap.set("n", "<leader>ft", "<CMD>TodoTelescope<CR>")
        end,
    },
    { "hrsh7th/nvim-cmp",
        dependencies = {
            "hrsh7th/cmp-nvim-lsp",
            "hrsh7th/cmp-buffer",
            "hrsh7th/cmp-path",
            "neovim/nvim-lspconfig",
        },
        config = function()
            local cmp = require("cmp")
            cmp.setup({
                mapping = cmp.mapping.preset.insert({
                    ["<C-Space>"] = cmp.mapping.complete(),
                    ["<Tab>"]     = cmp.mapping.select_next_item(),
                    ["<S-Tab>"]   = cmp.mapping.select_prev_item(),
                    ["<CR>"]      = cmp.mapping.confirm({ select = true }),
                    ["<Esc>"]     = cmp.mapping.abort(),
                }),
                completion = {
                    autocomplete = false,
                },
                sources = cmp.config.sources({
                    { name = "nvim_lsp" },
                    { name = "buffer" },
                    { name = "path" },
                }),
            })

            local caps = require("cmp_nvim_lsp").default_capabilities()
            vim.lsp.config("clangd", { capabilities = caps })
            vim.lsp.enable("clangd")

            vim.keymap.set("n", "gd", vim.lsp.buf.definition)
            vim.keymap.set("n", "gr", vim.lsp.buf.references)
            vim.keymap.set("n", "K",  vim.lsp.buf.hover)
            vim.keymap.set("n", "<leader>r", vim.lsp.buf.rename)
            vim.keymap.set("n", "<leader>a", vim.lsp.buf.code_action)

            vim.diagnostic.config({
                virtual_text = true,
                signs = true,
                underline = true,
            })
        end,
    },

})


vim.api.nvim_create_autocmd("ColorScheme", {
    pattern = "*",
    callback = function()
        vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
        vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })
        vim.api.nvim_set_hl(0, "NormalNC", { bg = "none" })
        vim.api.nvim_set_hl(0, "SignColumn", { bg = "none" })
        vim.api.nvim_set_hl(0, "LineNr", { bg = "none" })
    end,
})

vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })
vim.api.nvim_set_hl(0, "NormalNC", { bg = "none" })
vim.api.nvim_set_hl(0, "SignColumn", { bg = "none" })
vim.api.nvim_set_hl(0, "LineNr", { bg = "none" })


-- --- 1. SETTINGS & UI ---
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.mouse = 'a'
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.termguicolors = true
vim.opt.background = "dark"
vim.g.mapleader = " "

-- --- 2. THEME & TOGGLE (<leader>t) ---
pcall(vim.cmd.colorscheme, "kanagawa-dragon")
local themes = { "gruber-darker", "kanagawa-dragon", "oxocarbon", "tokyonight-night" }
local theme_idx = 1
local function toggle_theme()
    theme_idx = (theme_idx % #themes) + 1
    vim.cmd.colorscheme(themes[theme_idx])
    print("Switched to " .. themes[theme_idx])
end

vim.keymap.set("n", "<leader>t", toggle_theme)

-- --- 3. THE "TYPO" COMMANDS & SHELL SHORTCUT ---
vim.api.nvim_create_user_command('W', 'w', {})
vim.api.nvim_create_user_command('Wq', 'wq', {})
vim.api.nvim_create_user_command('WQ', 'wq', {})
vim.api.nvim_create_user_command('Q', 'q', {})

-- Press 'S' to start a manual shell command (e.g., S ls -la)
vim.keymap.set("n", "S", ":!")

vim.keymap.set("n", "<leader>s", "<CMD>split | terminal<CR>i")


-- --- 5. SMART EXECUTION (<leader>x) ---
local function smart_run()
    vim.cmd("write")
    if vim.fn.filereadable("build.sh") == 1 then
        vim.cmd("!chmod +x build.sh && ./build.sh")
    elseif vim.fn.filereadable("Makefile") == 1 then
        vim.cmd("!make && ./out")
    else
        local file = vim.fn.expand('%')
        vim.cmd("!gcc " .. file .. " -o out && ./out")
    end
end

local function compile_script()
    vim.cmd("write")
    if vim.fn.filereadable("compile.sh") == 1 then
        vim.cmd("!chmod +x compile.sh && ./compile.sh")
    end
end

local function run_script()
    vim.cmd("write")
    if vim.fn.filereadable("run.sh") == 1 then
        vim.cmd("!chmod +x run.sh && ./run.sh")
    end
end

vim.keymap.set("n", "<leader>x", smart_run)
vim.keymap.set("n", "<leader>z", compile_script)
vim.keymap.set("n", "<leader>c", run_script)
vim.keymap.set("v", ">", ">gv")
vim.keymap.set("v", "<", "<gv")

-- --- 6. TABS, CLIPBOARD & TERMINAL ESCAPE ---
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.clipboard = "unnamedplus"
vim.keymap.set("t", "<Esc>", [[<C-\><C-n>]])
