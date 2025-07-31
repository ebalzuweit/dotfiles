-- Main toggleterm configuration
return {
    "akinsho/toggleterm.nvim",
    version = "*",
    cmd = "ToggleTerm",
    opts = {
        size = function(term)
            if term.direction == "horizontal" then
                return 15
            elseif term.direction == "vertical" then
                return vim.o.columns * 0.33
            end
        end,
        open_mapping = [[<C-t>]],
        hide_numbers = true,
        direction = "vertical",
        shade_filetypes = {},
        autochdir = false,
    },
    config = function(_, opts)
        require("toggleterm").setup(opts)

        -- Load all terminal configurations
        require("plugins.toggleterm.floating").setup()
        require("plugins.toggleterm.buffer").setup()
        require("plugins.toggleterm.horizontal").setup()
        require("plugins.toggleterm.vertical").setup()
    end,
    -- Combine all keymaps from terminal modules
    keys = function()
        local keys = {}
        
        -- Get keymaps from all modules
        local modules = {
            require("plugins.toggleterm.floating"),
            require("plugins.toggleterm.buffer"),
            require("plugins.toggleterm.horizontal"),
            require("plugins.toggleterm.vertical"),
        }
        
        for _, module in ipairs(modules) do
            if module.keymaps then
                vim.list_extend(keys, module.keymaps())
            end
        end
        
        return keys
    end,
}