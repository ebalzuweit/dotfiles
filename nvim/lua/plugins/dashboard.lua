return {
    {
        "folke/snacks.nvim",
        priority = 1000,
        lazy = false,
        ---@type snacks.Config
        opts = {
            dashboard = {
                enabled = true,
                preset = {
                    pick = function(cmd, opts)
                        return LazyVim.pick(cmd, opts)()
                    end,
                    -- https://patorjk.com/software/taag/#p=display&f=Fraktur&t=HackerMan
                    header = [[
  _____                   _             _       _             _    _      
 |_   _|__ _ __ _ __ ___ (_)_ __   __ _| |     | |_   _ _ __ | | _(_) ___ 
   | |/ _ \ '__| '_ ` _ \| | '_ \ / _` | |  _  | | | | | '_ \| |/ / |/ _ \
   | |  __/ |  | | | | | | | | | | (_| | | | |_| | |_| | | | |   <| |  __/
   |_|\___|_|  |_| |_| |_|_|_| |_|\__,_|_|  \___/ \__,_|_| |_|_|\_\_|\___|
                                                                                                                                                                                               
]],
        -- stylua: ignore
        ---@type snacks.dashboard.Item[]
        keys = {
          { icon = " ", key = "f", desc = "Find File", action = ":lua Snacks.dashboard.pick('files')" },
          { icon = " ", key = "n", desc = "New File", action = ":ene | startinsert" },
          { icon = " ", key = "g", desc = "Find Text", action = ":lua Snacks.dashboard.pick('live_grep')" },
          { icon = " ", key = "r", desc = "Recent Files", action = ":lua Snacks.dashboard.pick('oldfiles')" },
          { icon = " ", key = "c", desc = "Config", action = ":lua Snacks.dashboard.pick('files', {cwd = vim.fn.stdpath('config')})" },
          { icon = " ", key = "s", desc = "Restore Session", section = "session" },
          { icon = " ", key = "x", desc = "Lazy Extras", action = ":LazyExtras" },
          { icon = "󰒲 ", key = "l", desc = "Lazy", action = ":Lazy" },
          { icon = " ", key = "q", desc = "Quit", action = ":qa" },
        },
                },
            },
        },
    },
}
