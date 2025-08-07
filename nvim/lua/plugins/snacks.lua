return {
  "folke/snacks.nvim",
  opts = {
    explorer = {
      filters = {
        dotfiles = false, -- Show dotfiles
        git_ignored = false, -- Show git ignored files
        custom = {}, -- No custom filters
      },
    },
    notifier = {
      enabled = true,
      timeout = 3000, -- default timeout in ms
      width = { min = 40, max = 0.4 },
      height = { min = 1, max = 0.6 },
      margin = { top = 0, right = 1, bottom = 0 },
      padding = true,
      sort = { "level", "added" },
      icons = {
        error = " ",
        warn = " ",
        info = " ",
        debug = " ",
        trace = " ",
      },
      style = "compact", -- "compact" or "fancy"
      top_down = false, -- place notifications from top to bottom
      date_format = "%R", -- time format
    },
  },
}