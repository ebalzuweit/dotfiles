-- lazy.nvim configuration
return {
    {
        "tpope/vim-dadbod",
        dependencies = {
            "kristijanhusak/vim-dadbod-ui",
            "kristijanhusak/vim-dadbod-pgsql", -- PostgreSQL driver
        },
        config = function()
            -- Optional: Set leader keys for easier access
            vim.g.db_ui_use_nerd_fonts = 1
            vim.keymap.set("n", "<leader>db", ":DBUIToggle<CR>", { desc = "Toggle DB UI" })
        end,
    },
}
