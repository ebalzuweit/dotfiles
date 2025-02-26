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
                                                  ..                                  ...     ..      ..                               
         .xHL                               < .z@8"`                                x*8888x.:*8888: -"888:                             
      .-`8888hxxx~                           !@88E                      .u    .    X   48888X `8888H  8888                  u.    u.   
   .H8X  `%888*"            u           .    '888E   u         .u     .d88B :@8c  X8x.  8888X  8888X  !888>        u      x@88k u@88c. 
   888X     ..x..        us888u.   .udR88N    888E u@8NL    ud8888.  ="8888f8888r X8888 X8888  88888   "*8%-    us888u.  ^"8888""8888" 
  '8888k .x8888888x   .@88 "8888" <888'888k   888E`"88*"  :888'8888.   4888>'88"  '*888!X8888> X8888  xH8>   .@88 "8888"   8888  888R  
   ?8888X    "88888X  9888  9888  9888 'Y"    888E .dN.   d888 '88%"   4888> '      `?8 `8888  X888X X888>   9888  9888    8888  888R  
    ?8888X    '88888> 9888  9888  9888        888E~8888   8888.+"      4888>        -^  '888"  X888  8888>   9888  9888    8888  888R  
 H8H %8888     `8888> 9888  9888  9888        888E '888&  8888L       .d888L .+      dx '88~x. !88~  8888>   9888  9888    8888  888R  
'888> 888"      8888  9888  9888  ?8888u../   888E  9888. '8888c. .+  ^"8888*"     .8888Xf.888x:!    X888X.: 9888  9888   "*88*" 8888" 
 "8` .8" ..     88*   "888*""888"  "8888P'  '"888*" 4888"  "88888%       "Y"      :""888":~"888"     `888*"  "888*""888"    ""   'Y"   
    `  x8888h. d*"     ^Y"   ^Y'     "P'       ""    ""      "YP'                     "~'    "~        ""     ^Y"   ^Y'                
      !""*888%~                                                                                                                        
      !   `"  .                                                                                                                        
      '-....:~                                                                                                                         
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
