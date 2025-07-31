return {
  "mfussenegger/nvim-lint",
  event = { "BufReadPre", "BufNewFile" },
  config = function()
    local lint = require("lint")
    
    -- Configure linters by filetype
    lint.linters_by_ft = {
      go = { "golangci-lint" },
    }
    
    -- Configure golangci-lint to use the Mason-installed binary
    lint.linters.golangci_lint = {
      cmd = vim.fn.stdpath("data") .. "/mason/bin/golangci-lint",
      args = {
        "run",
        "--out-format",
        "json",
        "--issues-exit-code=1",
      },
      stdin = false,
      append_fname = true,
      ignore_exitcode = true,
      parser = require("lint.parser").from_pattern(
        [[(%d+):(%d+): (.+)]],
        { "lnum", "col", "message" }
      ),
    }
    
    -- Create autocommand to trigger linting
    local lint_augroup = vim.api.nvim_create_augroup("lint", { clear = true })
    vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave" }, {
      group = lint_augroup,
      callback = function()
        lint.try_lint()
      end,
    })
  end,
}