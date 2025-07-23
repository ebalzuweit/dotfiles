return {
    "pwntester/octo.nvim",
    -- These dependencies are already included in LazyVim,
    -- but it's good practice to specify them.
    dependencies = {
        "nvim-lua/plenary.nvim",
        "nvim-telescope/telescope.nvim",
        "nvim-tree/nvim-web-devicons",
    },
    -- LazyVim will automatically call the setup function,
    -- but you can add custom configuration here if needed.
    config = function()
        require("octo").setup({
            -- You can add any custom octo.nvim settings here
            -- For example:
            -- reaction_icon = "👍",
        })

        -- Optional: Add keymaps for easier access
        vim.keymap.set("n", "<leader>gp", "<cmd>Octo pr list<cr>", { desc = "Octo - List PRs" })
    end,
}
