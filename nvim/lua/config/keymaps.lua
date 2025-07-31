-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- Escape Terminal mode with <Esc><Esc>
vim.keymap.set("t", "<Esc><Esc>", "<C-\\><C-n>", {})

-- Swap 0 and ^ keybindings
vim.keymap.set({ "n", "v" }, "0", "^", { desc = "Go to first non-blank character" })
vim.keymap.set({ "n", "v" }, "^", "0", { desc = "Go to beginning of line" })

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
  elseif vim.fn.exists(":Snacks") == 2 then
    Snacks.picker.buffers()
  else
    vim.notify("No buffer picker available", vim.log.levels.WARN)
  end
end, { desc = "Search open buffers" })

-- Alternative buffer search with Telescope
vim.keymap.set("n", "<leader>fb", "<cmd>Telescope buffers<cr>", { desc = "Find buffers" })

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
