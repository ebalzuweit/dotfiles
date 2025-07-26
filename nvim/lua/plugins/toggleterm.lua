-- lua/plugins/toggleterm.lua (example with minimal config)
return {
    "akinsho/toggleterm.nvim",
    version = "*",
    cmd = "ToggleTerm", -- Register command for LazyVim
    opts = {
        -- This 'size' function is for the *default* terminal (toggled by <C-t>)
        size = function(term)
            if term.direction == "horizontal" then
                -- Default horizontal terminal height (e.g., if <C-t> opens horizontal)
                return 15
            elseif term.direction == "vertical" then
                -- Default vertical terminal width (e.g., if <C-t> opens vertical)
                return vim.o.columns * 0.33
            end
        end,
        open_mapping = [[<C-t>]], -- Key to toggle the default terminal
        hide_numbers = true, -- hide the number column in the terminal
        direction = "vertical", -- Default direction when you open it with <C-t>
        shade_filetypes = {},
        autochdir = false, -- or true if you want the terminal to cd into the current file's directory
        -- Other options...
    },
    config = function(_, opts)
        require("toggleterm").setup(opts)

        -- Define a specific command and keymap for a 33% vertical terminal
        vim.api.nvim_create_user_command(
            "TermV33", -- Unique command name for vertical 33% width
            function()
                local term = require("toggleterm.terminal").Terminal:new({
                    direction = "vertical",
                    size = vim.o.columns * 0.33, -- Explicitly set width for this command (33% of columns)
                    hidden = true, -- Start hidden, then toggle visible
                })
                -- Wrap toggle in vim.schedule to ensure it runs in the next event loop cycle
                vim.schedule(function()
                    term:toggle()
                end)
            end,
            { nargs = 0, desc = "Toggle 33% Vertical Terminal" }
        )

        -- === Horizontal terminal at 33% height ===
        vim.api.nvim_create_user_command(
            "TermH33", -- UNIQUE command name for horizontal 33% height
            function()
                local term = require("toggleterm.terminal").Terminal:new({
                    direction = "horizontal",
                    size = vim.o.lines * 0.33, -- Explicitly set height for this command (33% of lines)
                    hidden = true, -- Start hidden, then toggle visible
                })
                -- Wrap toggle in vim.schedule to ensure it runs in the next event loop cycle
                vim.schedule(function()
                    term:toggle()
                end)
            end,
            { nargs = 0, desc = "Toggle 33% Horizontal Terminal" }
        )

        -- Define a specific command and keymap for a 50% vertical terminal
        vim.api.nvim_create_user_command(
            "TermV50", -- Unique command name for vertical 50% width
            function()
                local term = require("toggleterm.terminal").Terminal:new({
                    direction = "vertical",
                    size = vim.o.columns * 0.50, -- Explicitly set width for this command (50% of columns)
                    hidden = true, -- Start hidden, then toggle visible
                })
                -- Wrap toggle in vim.schedule to ensure it runs in the next event loop cycle
                vim.schedule(function()
                    term:toggle()
                end)
            end,
            { nargs = 0, desc = "Toggle 50% Vertical Terminal" }
        )

        -- === Horizontal terminal at 50% height ===
        vim.api.nvim_create_user_command(
            "TermH50", -- UNIQUE command name for horizontal 50% height
            function()
                local term = require("toggleterm.terminal").Terminal:new({
                    direction = "horizontal",
                    size = vim.o.lines * 0.5, -- Explicitly set height for this command (50% of lines)
                    hidden = true, -- Start hidden, then toggle visible
                })
                -- Wrap toggle in vim.schedule to ensure it runs in the next event loop cycle
                vim.schedule(function()
                    term:toggle()
                end)
            end,
            { nargs = 0, desc = "Toggle 50% Horizontal Terminal" }
        )

        -- === Floating terminal for 'gemini' command ===
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
            -- Wrap toggle in vim.schedule to ensure it runs in the next event loop cycle
            vim.schedule(function()
                term:toggle()
            end)
        end, { nargs = 0, desc = "Toggle Floating Gemini Terminal" })

        -- === Floating terminal for 'gemini' command ===
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
            -- Wrap toggle in vim.schedule to ensure it runs in the next event loop cycle
            vim.schedule(function()
                term:toggle()
            end)
        end, { nargs = 0, desc = "Toggle Floating Kuberenetes Terminal" })

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
            -- Wrap toggle in vim.schedule to ensure it runs in the next event loop cycle
            vim.schedule(function()
                term:toggle()
            end)
        end, { nargs = 0, desc = "Toggle Floating Yazi Terminal" })

        vim.api.nvim_create_user_command("BluetoothTerm", function()
            local term = require("toggleterm.terminal").Terminal:new({
                cmd = "btui",
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
            -- Wrap toggle in vim.schedule to ensure it runs in the next event loop cycle
            vim.schedule(function()
                term:toggle()
            end)
        end, { nargs = 0, desc = "Toggle Floating Bluetooth Terminal" })

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
            -- Wrap toggle in vim.schedule to ensure it runs in the next event loop cycle
            vim.schedule(function()
                term:toggle()
            end)
        end, { nargs = 0, desc = "Toggle Floating Claude Terminal" })

        vim.api.nvim_create_user_command("TermFF", function()
            local term = require("toggleterm.terminal").Terminal:new({
                -- Explicitly start zsh and tell it to run the 'ff' function
                direction = "float",
                float_opts = {
                    border = "curved",
                    width = math.floor(vim.o.columns * 0.8),
                    height = math.floor(vim.o.lines * 0.8),
                    row = math.floor((vim.o.lines - (vim.o.lines * 0.8)) / 2),
                    col = math.floor((vim.o.columns - (vim.o.columns * 0.8)) / 2),
                },
                hidden = true,
                -- No on_exit here, as you might want to keep 'ff' open for multiple searches
                -- and interact with the terminal after 'ff' completes.
            })
            vim.schedule(function()
                term:toggle()
            end)
        end, { nargs = 0, desc = "Toggle Floating Terminal with Fuzzy Folder Finder (ff)" })
    end,

    -- Keymaps for all terminals
    keys = {
        { "<leader>tvt", "<cmd>TermV33<CR>", desc = "Toggle 33% Vertical Terminal" },
        { "<leader>tht", "<cmd>TermH33<CR>", desc = "Toggle 33% Horizontal Terminal" },
        { "<leader>tvh", "<cmd>TermV50<CR>", desc = "Toggle 50% Vertical Terminal" },
        { "<leader>thh", "<cmd>TermH50<CR>", desc = "Toggle 50% Horizontal Terminal" },
        -- === Keymaps for Fuzzy Finders and General Floating Terminals ===
        { "<leader>tff", "<cmd>TermFF<CR>", desc = "Toggle General Floating Terminal" },
        { "<leader>tg", "<cmd>GeminiTerm<CR>", desc = "Toggle Floating Gemini Terminal" },
        { "<leader>tk", "<cmd>KubernetesTerm<CR>", desc = "Toggle Floating Kuberenetes Terminal" },
        { "<leader>ty", "<cmd>YaziTerm<CR>", desc = "Toggle Floating Yazi Terminal" },
        { "<leader>ty", "<cmd>ClaudeTerm<CR>", desc = "Toggle Floating Claude Terminal" },
        { "<leader>tb", "<cmd>BluetoothTerm<CR>", desc = "Toggle Floating Bluetooth Terminal" },
    },
}
