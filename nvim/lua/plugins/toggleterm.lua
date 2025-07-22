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

        -- === CORRECTED & NEW: Horizontal terminal at 33% height ===
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

        -- === Existing: Floating terminal for 'gemini' command ===
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

        -- === NEW: Floating terminal running ff_term_horizontal ===
        vim.api.nvim_create_user_command("TermFFH", function()
            local term = require("toggleterm.terminal").Terminal:new({
                cmd = "ff_term_horizontal", -- This will run the shell script
                direction = "float",
                float_opts = {
                    border = "curved",
                    width = math.floor(vim.o.columns * 0.8),
                    height = math.floor(vim.o.lines * 0.8),
                    row = math.floor((vim.o.lines - (vim.o.lines * 0.8)) / 2),
                    col = math.floor((vim.o.columns - (vim.o.columns * 0.8)) / 2),
                },
                hidden = true,
                -- This on_exit callback is crucial to close the temporary floating terminal
                -- after the ff_term_horizontal script has completed.
                on_exit = function(t)
                    vim.schedule(function()
                        t:close()
                    end)
                end,
            })
            vim.schedule(function()
                term:toggle()
            end)
        end, { nargs = 0, desc = "Fuzzy Find Folder and Open Horizontal Terminal" })

        -- === NEW: Floating terminal running ff_term_vertical ===
        vim.api.nvim_create_user_command("TermFFV", function()
            local term = require("toggleterm.terminal").Terminal:new({
                cmd = "ff_term_vertical", -- This will run the shell script
                direction = "float",
                float_opts = {
                    border = "curved",
                    width = math.floor(vim.o.columns * 0.8),
                    height = math.floor(vim.o.lines * 0.8),
                    row = math.floor((vim.o.lines - (vim.o.lines * 0.8)) / 2),
                    col = math.floor((vim.o.columns - (vim.o.columns * 0.8)) / 2),
                },
                hidden = true,
                on_exit = function(t)
                    vim.schedule(function()
                        t:close()
                    end)
                end,
            })
            vim.schedule(function()
                term:toggle()
            end)
        end, { nargs = 0, desc = "Fuzzy Find Folder and Open Vertical Terminal" })
    end,
    -- Keymaps for all terminals
    keys = {
        { "<leader>tv", "<cmd>TermV33<CR>", desc = "Toggle 33% Vertical Terminal" },
        { "<leader>th", "<cmd>TermH33<CR>", desc = "Toggle 33% Horizontal Terminal" },
        { "<leader>tg", "<cmd>GeminiTerm<CR>", desc = "Toggle Floating Gemini Terminal" },
        -- === NEW KEYMAPS ===
        { "<leader>tfh", "<cmd>TermFFH<CR>", desc = "Fuzzy Find Folder & Open Horizontal Terminal" },
        { "<leader>tfv", "<cmd>TermFFV<CR>", desc = "Fuzzy Find Folder & Open Vertical Terminal" },
    },
}
