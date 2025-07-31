-- Floating terminal configurations
local M = {}

function M.setup()
    -- Gemini Terminal
    vim.api.nvim_create_user_command("GeminiTerm", function()
        local term = require("toggleterm.terminal").Terminal:new({
            cmd = "gemini",
            direction = "float",
            float_opts = {
                border = "curved",
                width = math.floor(vim.o.columns * 0.8),
                height = math.floor(vim.o.lines * 0.8),
                row = math.floor((vim.o.lines - (vim.o.lines * 0.8)) / 2),
                col = math.floor((vim.o.columns - (vim.o.columns * 0.8)) / 2),
            },
            hidden = true,
        })
        vim.schedule(function()
            term:toggle()
        end)
    end, { nargs = 0, desc = "Toggle Floating Gemini Terminal" })

    -- Kubernetes Terminal
    vim.api.nvim_create_user_command("KubernetesTerm", function()
        local term = require("toggleterm.terminal").Terminal:new({
            cmd = "k9s",
            direction = "float",
            float_opts = {
                border = "curved",
                width = math.floor(vim.o.columns * 0.8),
                height = math.floor(vim.o.lines * 0.8),
                row = math.floor((vim.o.lines - (vim.o.lines * 0.8)) / 2),
                col = math.floor((vim.o.columns - (vim.o.columns * 0.8)) / 2),
            },
            hidden = true,
        })
        vim.schedule(function()
            term:toggle()
        end)
    end, { nargs = 0, desc = "Toggle Floating Kubernetes Terminal" })

    -- Yazi Terminal
    vim.api.nvim_create_user_command("YaziTerm", function()
        local term = require("toggleterm.terminal").Terminal:new({
            cmd = "yazi",
            direction = "float",
            float_opts = {
                border = "curved",
                width = math.floor(vim.o.columns * 0.8),
                height = math.floor(vim.o.lines * 0.8),
                row = math.floor((vim.o.lines - (vim.o.lines * 0.8)) / 2),
                col = math.floor((vim.o.columns - (vim.o.columns * 0.8)) / 2),
            },
            hidden = true,
        })
        vim.schedule(function()
            term:toggle()
        end)
    end, { nargs = 0, desc = "Toggle Floating Yazi Terminal" })

    -- Bluetooth Terminal
    vim.api.nvim_create_user_command("BluetoothTerm", function()
        local term = require("toggleterm.terminal").Terminal:new({
            cmd = "bluetooth-tui",
            direction = "float",
            float_opts = {
                border = "curved",
                width = math.floor(vim.o.columns * 0.8),
                height = math.floor(vim.o.lines * 0.8),
                row = math.floor((vim.o.lines - (vim.o.lines * 0.8)) / 2),
                col = math.floor((vim.o.columns - (vim.o.columns * 0.8)) / 2),
            },
            hidden = true,
        })
        vim.schedule(function()
            term:toggle()
        end)
    end, { nargs = 0, desc = "Toggle Floating Bluetooth Terminal" })

    -- Claude Terminal
    vim.api.nvim_create_user_command("ClaudeTerm", function()
        local term = require("toggleterm.terminal").Terminal:new({
            cmd = "claude",
            direction = "float",
            float_opts = {
                border = "curved",
                width = math.floor(vim.o.columns * 0.8),
                height = math.floor(vim.o.lines * 0.8),
                row = math.floor((vim.o.lines - (vim.o.lines * 0.8)) / 2),
                col = math.floor((vim.o.columns - (vim.o.columns * 0.8)) / 2),
            },
            hidden = true,
        })
        vim.schedule(function()
            term:toggle()
        end)
    end, { nargs = 0, desc = "Toggle Floating Claude Terminal" })

    -- General Floating Terminal
    vim.api.nvim_create_user_command("TermFF", function()
        local term = require("toggleterm.terminal").Terminal:new({
            direction = "float",
            float_opts = {
                border = "curved",
                width = math.floor(vim.o.columns * 0.8),
                height = math.floor(vim.o.lines * 0.8),
                row = math.floor((vim.o.lines - (vim.o.lines * 0.8)) / 2),
                col = math.floor((vim.o.columns - (vim.o.columns * 0.8)) / 2),
            },
            hidden = true,
        })
        vim.schedule(function()
            term:toggle()
        end)
    end, { nargs = 0, desc = "Toggle Floating Terminal with Fuzzy Folder Finder (ff)" })

    -- Quill Terminal
    vim.api.nvim_create_user_command("QuillTerm", function()
        local term = require("toggleterm.terminal").Terminal:new({
            cmd = "quill",
            direction = "float",
            float_opts = {
                border = "curved",
                width = math.floor(vim.o.columns * 0.8),
                height = math.floor(vim.o.lines * 0.8),
                row = math.floor((vim.o.lines - (vim.o.lines * 0.8)) / 2),
                col = math.floor((vim.o.columns - (vim.o.columns * 0.8)) / 2),
            },
            hidden = true,
        })
        vim.schedule(function()
            term:toggle()
        end)
    end, { nargs = 0, desc = "Toggle Floating Terminal with Quill" })

    -- Azure Searcher Terminal
    vim.api.nvim_create_user_command("AzureSearcherTerm", function()
        local term = require("toggleterm.terminal").Terminal:new({
            cmd = "azure-searcher",
            direction = "float",
            float_opts = {
                border = "curved",
                width = math.floor(vim.o.columns * 0.8),
                height = math.floor(vim.o.lines * 0.8),
                row = math.floor((vim.o.lines - (vim.o.lines * 0.8)) / 2),
                col = math.floor((vim.o.columns - (vim.o.columns * 0.8)) / 2),
            },
            hidden = true,
        })
        vim.schedule(function()
            term:toggle()
        end)
    end, { nargs = 0, desc = "Toggle Floating Terminal with Azure Searcher" })
end

-- Return keymaps for floating terminals
function M.keymaps()
    return {
        { "<leader>tff", "<cmd>TermFF<CR>", desc = "Toggle General Floating Terminal" },
        { "<leader>tfg", "<cmd>GeminiTerm<CR>", desc = "Toggle Floating Gemini Terminal" },
        { "<leader>tfk", "<cmd>KubernetesTerm<CR>", desc = "Toggle Floating Kubernetes Terminal" },
        { "<leader>tfy", "<cmd>YaziTerm<CR>", desc = "Toggle Floating Yazi Terminal" },
        { "<leader>tfc", "<cmd>ClaudeTerm<CR>", desc = "Toggle Floating Claude Terminal" },
        { "<leader>tfb", "<cmd>BluetoothTerm<CR>", desc = "Toggle Floating Bluetooth Terminal" },
        { "<leader>tfq", "<cmd>QuillTerm<CR>", desc = "Toggle Floating Quill Terminal" },
        { "<leader>tfa", "<cmd>AzureSearcherTerm<CR>", desc = "Toggle Floating Azure Searcher Terminal" },
    }
end

return M