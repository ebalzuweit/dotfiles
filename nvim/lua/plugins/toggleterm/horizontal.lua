-- Horizontal terminal configurations
local M = {}

function M.setup()
    -- 33% Horizontal Terminal
    vim.api.nvim_create_user_command("TermH33", function()
        local term = require("toggleterm.terminal").Terminal:new({
            direction = "horizontal",
            size = vim.o.lines * 0.33,
            hidden = true,
        })
        vim.schedule(function()
            term:toggle()
        end)
    end, { nargs = 0, desc = "Toggle 33% Horizontal Terminal" })

    -- 50% Horizontal Terminal
    vim.api.nvim_create_user_command("TermH50", function()
        local term = require("toggleterm.terminal").Terminal:new({
            direction = "horizontal",
            size = vim.o.lines * 0.5,
            hidden = true,
        })
        vim.schedule(function()
            term:toggle()
        end)
    end, { nargs = 0, desc = "Toggle 50% Horizontal Terminal" })
end

-- Return keymaps for horizontal terminals
function M.keymaps()
    return {
        { "<leader>tht", "<cmd>TermH33<CR>", desc = "Toggle 33% Horizontal Terminal" },
        { "<leader>thh", "<cmd>TermH50<CR>", desc = "Toggle 50% Horizontal Terminal" },
    }
end

return M