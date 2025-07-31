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
        { "<leader>tr", "<cmd>TerminalRename<CR>", desc = "Rename Terminal Buffer" },
    }
end

return M