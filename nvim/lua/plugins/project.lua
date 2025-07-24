return {
    "ahmedkhalf/project.nvim",
    dependencies = { "nvim-telescope/telescope.nvim" },
    -- The keys to trigger the plugin's actions
    keys = {
        { "<leader>fp", "<cmd>Telescope projects<CR>", desc = "Find Projects" },
        {
            "<leader>pn",
            function()
                -- Close all buffers
                local bufs = vim.api.nvim_list_bufs()
                for _, buf in ipairs(bufs) do
                    if vim.bo[buf].buflisted then
                        vim.api.nvim_buf_delete(buf, { force = true })
                    end
                end
                -- Open and focus the file manager
                vim.cmd("Neotree")
            end,
            { desc = "New Project (close buffers, open tree)" },
        },
    },
    -- The config function runs after the plugin is loaded
    config = function()
        require("project_nvim").setup({
            -- This function runs when you select a project from the Telescope list
            on_project_selected = function(path)
                -- Change the current directory to the selected project's path
                vim.cmd("cd " .. path)

                -- Close all existing buffers
                local bufs = vim.api.nvim_list_bufs()
                for _, buf in ipairs(bufs) do
                    if vim.bo[buf].buflisted then
                        vim.api.nvim_buf_delete(buf, { force = true })
                    end
                end

                -- Open the file manager
                vim.cmd("Neotree")
            end,
        })

        -- Load the telescope extension
        require("telescope").load_extension("projects")
    end,
}
