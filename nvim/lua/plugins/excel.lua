return {
  -- CSV viewer with Excel-like navigation
  {
    "hat0uma/csvview.nvim",
    ft = { "csv", "tsv" },
    opts = {
      parser = {
        async = true,
        comments = { "#", "//" },
      },
      view = {
        display_mode = "highlight",
      },
      keymaps = {
        -- Excel-like navigation
        next_field = { "<Tab>", mode = { "n", "i", "x" } },
        prev_field = { "<S-Tab>", mode = { "n", "i", "x" } },
        next_line = { "<CR>", mode = { "n" } },
        prev_line = { "<S-CR>", mode = { "n" } },
        -- Text objects
        textobject_field_inner = { "if", mode = { "o", "x" } },
        textobject_field_outer = { "af", mode = { "o", "x" } },
        textobject_line_inner = { "il", mode = { "o", "x" } },
        textobject_line_outer = { "al", mode = { "o", "x" } },
      },
    },
    keys = {
      { "<leader>cv", "<cmd>CsvViewToggle<cr>", desc = "Toggle CSV view" },
    },
  },

  -- Basic Excel file viewer (read-only)
  {
    "ryanmorillo/excel.vim",
    ft = { "xls", "xlsx", "xlsm", "xltx", "xltm", "xlam" },
    config = function()
      -- Set Python3 host to use virtual environment
      vim.g.python3_host_prog = vim.fn.expand("~/.local/share/nvim/venv/bin/python")
    end,
    build = function()
      vim.notify("Excel.vim configured with Python virtual environment", vim.log.levels.INFO)
    end,
  },
}