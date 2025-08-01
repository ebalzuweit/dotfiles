-- Buffer terminal configurations
local M = {}

-- Helper function to set terminal buffer name with icon
local function set_terminal_name(name)
    -- If name is empty, use default "terminal"
    if name == "" or name == nil then
        name = "terminal"
    end
    -- Add the $ icon prefix
    local full_name = "$ " .. name
    vim.cmd("file " .. vim.fn.fnameescape(full_name))
end

-- Helper function to setup terminal buffer autocmds
local function setup_terminal_autocmds()
    local augroup = vim.api.nvim_create_augroup("BufferTerminalNaming", { clear = true })
    
    -- Auto-name terminal buffers when they are created
    vim.api.nvim_create_autocmd("TermOpen", {
        group = augroup,
        pattern = "*",
        callback = function()
            -- Only apply to buffer terminals (not splits or floats)
            local win_config = vim.api.nvim_win_get_config(0)
            if not win_config.relative or win_config.relative == "" then
                -- Check if it's not a split by looking at window dimensions
                local win_height = vim.api.nvim_win_get_height(0)
                local win_width = vim.api.nvim_win_get_width(0)
                local total_height = vim.o.lines
                local total_width = vim.o.columns
                
                -- If the terminal takes up most of the screen, it's likely a buffer terminal
                if win_height >= total_height - 5 and win_width >= total_width - 5 then
                    -- Set default name
                    vim.schedule(function()
                        set_terminal_name("terminal")
                    end)
                end
            end
        end,
    })
end

function M.setup()
    -- Setup autocmds for terminal naming
    setup_terminal_autocmds()
    
    -- Claude Buffer Terminal
    vim.api.nvim_create_user_command("ClaudeBufferTerm", function()
        vim.cmd("terminal claude")
        vim.schedule(function()
            set_terminal_name("claude")
        end)
    end, { nargs = 0, desc = "Open Claude in Current Buffer" })

    -- Gemini Buffer Terminal
    vim.api.nvim_create_user_command("GeminiBufferTerm", function()
        vim.cmd("terminal gemini")
        vim.schedule(function()
            set_terminal_name("gemini")
        end)
    end, { nargs = 0, desc = "Open Gemini in Current Buffer" })


    -- Quill Buffer Terminal
    vim.api.nvim_create_user_command("QuillBufferTerm", function()
        vim.cmd("terminal quill")
        vim.schedule(function()
            set_terminal_name("quill")
        end)
    end, { nargs = 0, desc = "Open Quill in Current Buffer" })

    -- Kubernetes (k9s) Buffer Terminal
    vim.api.nvim_create_user_command("KubernetesBufferTerm", function()
        vim.cmd("terminal k9s")
        vim.schedule(function()
            set_terminal_name("k9s")
        end)
    end, { nargs = 0, desc = "Open Kubernetes (k9s) in Current Buffer" })

    -- Yazi Buffer Terminal
    vim.api.nvim_create_user_command("YaziBufferTerm", function()
        vim.cmd("terminal yazi")
        vim.schedule(function()
            set_terminal_name("yazi")
        end)
    end, { nargs = 0, desc = "Open Yazi in Current Buffer" })

    -- Bluetooth Buffer Terminal
    vim.api.nvim_create_user_command("BluetoothBufferTerm", function()
        vim.cmd("terminal bluetooth-tui")
        vim.schedule(function()
            set_terminal_name("bluetooth-tui")
        end)
    end, { nargs = 0, desc = "Open Bluetooth TUI in Current Buffer" })

    -- Azure Searcher Buffer Terminal
    vim.api.nvim_create_user_command("AzureSearcherBufferTerm", function()
        vim.cmd("terminal azure-searcher")
        vim.schedule(function()
            set_terminal_name("azure-searcher")
        end)
    end, { nargs = 0, desc = "Open Azure Searcher in Current Buffer" })

    -- General Buffer Terminal
    vim.api.nvim_create_user_command("BufferTerm", function()
        vim.cmd("terminal")
        vim.schedule(function()
            -- Prompt for terminal name
            local name = vim.fn.input("Terminal name (empty for default): ")
            set_terminal_name(name)
        end)
    end, { nargs = 0, desc = "Open Terminal in Current Buffer" })
    
    -- Terminal rename command
    vim.api.nvim_create_user_command("TerminalRename", function()
        -- Check if current buffer is a terminal
        if vim.bo.buftype ~= "terminal" then
            vim.notify("Current buffer is not a terminal", vim.log.levels.WARN)
            return
        end
        
        -- Get current name (remove the "$ " prefix if present)
        local current_name = vim.fn.expand("%:t")
        if current_name:sub(1, 2) == "$ " then
            current_name = current_name:sub(3)
        end
        
        -- Prompt for new name
        local new_name = vim.fn.input("New terminal name: ", current_name)
        
        -- Set the new name (empty input defaults to "terminal")
        set_terminal_name(new_name)
    end, { nargs = 0, desc = "Rename terminal buffer" })
end

-- Return keymaps for buffer terminals
function M.keymaps()
    return {
        { "<leader>tt", "<cmd>BufferTerm<CR>", desc = "Open Terminal in Current Buffer" },
        { "<leader>tc", "<cmd>ClaudeBufferTerm<CR>", desc = "Open Claude in Current Buffer" },
        { "<leader>tg", "<cmd>GeminiBufferTerm<CR>", desc = "Open Gemini in Current Buffer" },
        { "<leader>tq", "<cmd>QuillBufferTerm<CR>", desc = "Open Quill in Current Buffer" },
        { "<leader>tk", "<cmd>KubernetesBufferTerm<CR>", desc = "Open Kubernetes in Current Buffer" },
        { "<leader>ty", "<cmd>YaziBufferTerm<CR>", desc = "Open Yazi in Current Buffer" },
        { "<leader>tb", "<cmd>BluetoothBufferTerm<CR>", desc = "Open Bluetooth in Current Buffer" },
        { "<leader>ta", "<cmd>AzureSearcherBufferTerm<CR>", desc = "Open Azure Searcher in Current Buffer" },
        { "<leader>tr", "<cmd>TerminalRename<CR>", desc = "Rename Terminal Buffer" },
    }
end

return M