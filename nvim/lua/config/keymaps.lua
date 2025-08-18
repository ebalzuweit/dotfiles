-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- Escape Terminal mode with <Esc><Esc>
vim.keymap.set("t", "<Esc><Esc>", "<C-\\><C-n>", {})

-- Swap 0 and ^ keybindings
vim.keymap.set({ "n", "v" }, "0", "^", { desc = "Go to first non-blank character" })
vim.keymap.set({ "n", "v" }, "^", "0", { desc = "Go to beginning of line" })

-- Window navigation with Ctrl+H prefix (WASD-style)
vim.keymap.set("n", "<C-h>a", "<C-w>h", { desc = "Navigate to left window (WASD)" })
vim.keymap.set("n", "<C-h>s", "<C-w>j", { desc = "Navigate to lower window (WASD)" })
vim.keymap.set("n", "<C-h>w", "<C-w>k", { desc = "Navigate to upper window (WASD)" })
vim.keymap.set("n", "<C-h>d", "<C-w>l", { desc = "Navigate to right window (WASD)" })

-- Override <leader><leader> to use current window for file picker
vim.keymap.set("n", "<leader><leader>", function()
    -- Check if Snacks is available by trying to access it
    local ok, snacks = pcall(function()
        return Snacks
    end)
    if ok and snacks and snacks.picker then
        -- Use Snacks picker with edit action to open in current window
        snacks.picker.files({
            action = function(item, ctx)
                -- Edit in current window instead of split
                vim.cmd("edit " .. item.file)
            end,
        })
    elseif package.loaded["telescope"] then
        -- Fallback to Telescope if Snacks is not available
        require("telescope.builtin").find_files()
    else
        vim.notify("No file picker available", vim.log.levels.WARN)
    end
end, { desc = "Find files (current window)" })

-- Diagnostic keymaps
vim.keymap.set("n", "<leader>d", vim.diagnostic.open_float, { desc = "Open diagnostic float" })
vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, { desc = "Go to previous diagnostic" })
vim.keymap.set("n", "]d", vim.diagnostic.goto_next, { desc = "Go to next diagnostic" })
vim.keymap.set("n", "<leader>q", vim.diagnostic.setloclist, { desc = "Open diagnostics list" })

-- Buffer search keymaps
vim.keymap.set("n", "<leader>bf", function()
    if package.loaded["telescope"] then
        require("telescope.builtin").buffers({
            sort_mru = true,
            sort_lastused = true,
            show_all_buffers = true,
            previewer = require("telescope.config").values.file_previewer({}),
            attach_mappings = function(_, map)
                map("n", "dd", require("telescope.actions").delete_buffer)
                map("i", "<C-d>", require("telescope.actions").delete_buffer)
                return true
            end,
        })
    else
        local ok, snacks = pcall(function()
            return Snacks
        end)
        if ok and snacks and snacks.picker then
            snacks.picker.buffers()
        else
            vim.notify("No buffer picker available", vim.log.levels.WARN)
        end
    end
end, { desc = "Search open buffers" })

-- Alternative buffer search with Telescope
vim.keymap.set("n", "<leader>fb", "<cmd>Telescope buffers<cr>", { desc = "Find buffers" })

-- Mass buffer deletion with multi-select using Telescope
vim.keymap.set("n", "<leader>fBd", function()
    require("telescope.builtin").buffers({
        sort_mru = true,
        sort_lastused = true,
        show_all_buffers = true,
        prompt_title = "Delete Buffers (Tab to select multiple)",
        attach_mappings = function(prompt_bufnr, map)
            local actions = require("telescope.actions")
            local action_state = require("telescope.actions.state")

            -- Custom multi-select delete action
            actions.select_default:replace(function()
                local picker = action_state.get_current_picker(prompt_bufnr)
                local multi_selections = picker:get_multi_selection()

                if #multi_selections > 0 then
                    for _, entry in ipairs(multi_selections) do
                        vim.api.nvim_buf_delete(entry.bufnr, { force = false })
                    end
                    vim.notify(string.format("Deleted %d buffer(s)", #multi_selections), vim.log.levels.INFO)
                else
                    local selection = action_state.get_selected_entry()
                    if selection then
                        vim.api.nvim_buf_delete(selection.bufnr, { force = false })
                        vim.notify("Deleted 1 buffer", vim.log.levels.INFO)
                    end
                end
                actions.close(prompt_bufnr)
            end)

            -- Map Tab to toggle selection for multi-select
            map("i", "<Tab>", actions.toggle_selection + actions.move_selection_worse)
            map("i", "<S-Tab>", actions.toggle_selection + actions.move_selection_better)
            map("n", "<Tab>", actions.toggle_selection + actions.move_selection_worse)
            map("n", "<S-Tab>", actions.toggle_selection + actions.move_selection_better)

            return true
        end,
    })
end, { desc = "Find and delete buffers (multi-select)" })

-- Quick buffer delete current buffer
vim.keymap.set("n", "<leader>bd", function()
    local buf = vim.api.nvim_get_current_buf()
    local wins = vim.fn.getbufinfo(buf)[1].windows

    -- Check if this is the last window
    if #vim.api.nvim_list_wins() == 1 and #vim.fn.getbufinfo({ buflisted = 1 }) == 1 then
        vim.notify("Cannot delete the last buffer", vim.log.levels.WARN)
        return
    end

    -- Try to switch to alternate buffer or previous buffer before deleting
    if #wins > 0 then
        for _, win in ipairs(wins) do
            vim.api.nvim_set_current_win(win)
            vim.cmd("bprevious")
        end
    end

    -- Delete the buffer
    vim.api.nvim_buf_delete(buf, { force = false })
    vim.notify("Buffer deleted", vim.log.levels.INFO)
end, { desc = "Delete current buffer" })

-- Go specific keymaps
vim.api.nvim_create_autocmd("FileType", {
    pattern = "go",
    callback = function()
        -- Go specific mappings
        vim.keymap.set("n", "<leader>gt", "<cmd>GoTest<cr>", { buffer = true, desc = "Go Test" })
        vim.keymap.set("n", "<leader>gT", "<cmd>GoTestFunc<cr>", { buffer = true, desc = "Go Test Function" })
        vim.keymap.set("n", "<leader>gc", "<cmd>GoCoverage<cr>", { buffer = true, desc = "Go Coverage" })
        vim.keymap.set("n", "<leader>gl", "<cmd>GoLint<cr>", { buffer = true, desc = "Go Lint" })
        vim.keymap.set("n", "<leader>gi", "<cmd>GoImports<cr>", { buffer = true, desc = "Go Imports" })
        vim.keymap.set("n", "<leader>gv", "<cmd>GoVet<cr>", { buffer = true, desc = "Go Vet" })
    end,
})
