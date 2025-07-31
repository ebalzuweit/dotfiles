-- Vertical terminal configurations
local M = {}

function M.setup()
    -- 33% Vertical Terminal
    vim.api.nvim_create_user_command("TermV33", function()
        local term = require("toggleterm.terminal").Terminal:new({
            direction = "vertical",
            size = vim.o.columns * 0.33,
            hidden = true,
        })
        vim.schedule(function()
            term:toggle()
        end)
    end, { nargs = 0, desc = "Toggle 33% Vertical Terminal" })

    -- 50% Vertical Terminal
    vim.api.nvim_create_user_command("TermV50", function()
        local term = require("toggleterm.terminal").Terminal:new({
            direction = "vertical",
            size = vim.o.columns * 0.50,
            hidden = true,
        })
        vim.schedule(function()
            term:toggle()
        end)
    end, { nargs = 0, desc = "Toggle 50% Vertical Terminal" })
end

-- Return keymaps for vertical terminals
function M.keymaps()
    return {
        { "<leader>tvt", "<cmd>TermV33<CR>", desc = "Toggle 33% Vertical Terminal" },
        { "<leader>tvh", "<cmd>TermV50<CR>", desc = "Toggle 50% Vertical Terminal" },
    }
end

return M