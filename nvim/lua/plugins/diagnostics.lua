return {
  -- Enhanced diagnostics display
  {
    "folke/trouble.nvim",
    opts = {
      use_diagnostic_signs = true,
    },
  },

  -- Configure diagnostic display
  {
    "neovim/nvim-lspconfig",
    opts = {
      diagnostics = {
        underline = true,
        update_in_insert = true, -- Show diagnostics while typing
        virtual_text = {
          spacing = 4,
          source = "always", -- Always show source of diagnostic
          prefix = "●",
          severity = nil, -- Show all severities
          format = function(diagnostic)
            local severity = diagnostic.severity
            local prefix = ""
            if severity == vim.diagnostic.severity.ERROR then
              prefix = "[ERROR] "
            elseif severity == vim.diagnostic.severity.WARN then
              prefix = "[WARN] "
            elseif severity == vim.diagnostic.severity.INFO then
              prefix = "[INFO] "
            elseif severity == vim.diagnostic.severity.HINT then
              prefix = "[HINT] "
            end
            return prefix .. diagnostic.message
          end,
        },
        severity_sort = true,
        float = {
          focusable = false,
          style = "minimal",
          border = "rounded",
          source = "always",
          header = "",
          prefix = "",
        },
        signs = {
          text = {
            [vim.diagnostic.severity.ERROR] = " ",
            [vim.diagnostic.severity.WARN] = " ",
            [vim.diagnostic.severity.HINT] = " ",
            [vim.diagnostic.severity.INFO] = " ",
          },
        },
      },
    },
    config = function(_, opts)
      -- Configure diagnostics with enhanced inline display
      vim.diagnostic.config(vim.tbl_deep_extend("force", opts.diagnostics, {
        virtual_text = {
          spacing = 4,
          source = "always",
          prefix = function(diagnostic)
            local icons = {
              [vim.diagnostic.severity.ERROR] = " ",
              [vim.diagnostic.severity.WARN] = " ",
              [vim.diagnostic.severity.INFO] = " ",
              [vim.diagnostic.severity.HINT] = "󰌵 ",
            }
            return icons[diagnostic.severity] or "●"
          end,
          format = function(diagnostic)
            return string.format("%s [%s]", diagnostic.message, diagnostic.source or "")
          end,
        },
      }))

      -- Configure diagnostic signs
      for severity, icon in pairs(opts.diagnostics.signs.text) do
        local name = vim.diagnostic.severity[severity]:lower():gsub("^%l", string.upper)
        name = "DiagnosticSign" .. name
        vim.fn.sign_define(name, { text = icon, texthl = name, numhl = "" })
      end

      -- Highlight colors for virtual text
      vim.api.nvim_set_hl(0, "DiagnosticVirtualTextError", { link = "DiagnosticError" })
      vim.api.nvim_set_hl(0, "DiagnosticVirtualTextWarn", { link = "DiagnosticWarn" })
      vim.api.nvim_set_hl(0, "DiagnosticVirtualTextInfo", { link = "DiagnosticInfo" })
      vim.api.nvim_set_hl(0, "DiagnosticVirtualTextHint", { link = "DiagnosticHint" })

      -- Force immediate diagnostic updates
      vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave", "TextChanged" }, {
        pattern = "*.go",
        callback = function()
          vim.diagnostic.show(nil, 0)
        end,
      })

      -- Show diagnostics in hover window
      vim.api.nvim_create_autocmd("CursorHold", {
        callback = function()
          local opts = {
            focusable = false,
            close_events = { "BufLeave", "CursorMoved", "InsertEnter", "FocusLost" },
            border = "rounded",
            source = "always",
            prefix = " ",
            scope = "cursor",
          }
          vim.diagnostic.open_float(nil, opts)
        end,
      })

      -- Set update time for faster diagnostic display
      vim.o.updatetime = 250
    end,
  },

  -- Better diagnostics list
  {
    "folke/lsp-colors.nvim",
    event = "BufReadPre",
    config = true,
  },
}