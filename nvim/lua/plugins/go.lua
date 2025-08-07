return {
  -- Treesitter for enhanced syntax highlighting
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      if type(opts.ensure_installed) == "table" then
        vim.list_extend(opts.ensure_installed, { "go", "gomod", "gowork", "gosum" })
      end
    end,
  },

  -- Main LSP configuration with gopls
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
    },
    opts = {
      -- Enable inline diagnostics
      diagnostics = {
        underline = true,
        update_in_insert = true,
        virtual_text = {
          spacing = 4,
          source = "if_many",
          prefix = "●",
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
        signs = true,
      },
      -- Configure Go language server
      servers = {
        gopls = {
          settings = {
            gopls = {
              gofumpt = true,
              usePlaceholders = true,
              completeUnimported = true,
              staticcheck = true,
              directoryFilters = { "-.git", "-.vscode", "-.idea", "-.vscode-test", "-node_modules" },
              semanticTokens = true,
              -- Enable all analyses for better error detection
              analyses = {
                -- Unused code detection
                unusedparams = true,
                unusedwrite = true,
                unusedresult = true,
                deadcode = true,
                -- Type checking and errors
                nilness = true,
                shadow = true,
                fieldalignment = true,
                useany = true,
                assign = true,
                atomic = true,
                bools = true,
                composites = true,
                copylocks = true,
                deepequalerrors = true,
                embed = true,
                errorsas = true,
                httpresponse = true,
                ifaceassert = true,
                loopclosure = true,
                lostcancel = true,
                nilfunc = true,
                printf = true,
                shift = true,
                stdmethods = true,
                stringintconv = true,
                structtag = true,
                tests = true,
                unmarshal = true,
                unreachable = true,
                unsafeptr = true,
              },
              -- Hints for better code understanding
              hints = {
                assignVariableTypes = true,
                compositeLiteralFields = true,
                compositeLiteralTypes = true,
                constantValues = true,
                functionTypeParameters = true,
                parameterNames = true,
                rangeVariableTypes = true,
              },
              codelenses = {
                gc_details = false,
                generate = true,
                regenerate_cgo = true,
                run_govulncheck = true,
                test = true,
                tidy = true,
                upgrade_dependency = true,
                vendor = true,
              },
              -- Fast diagnostics
              diagnosticsDelay = "100ms",
              experimentalPostfixCompletions = true,
              matcher = "Fuzzy",
              symbolMatcher = "fuzzy",
              symbolStyle = "Dynamic",
            },
          },
        },
      },
    },
    config = function(_, opts)
      -- Setup diagnostics display
      vim.diagnostic.config({
        underline = true,
        update_in_insert = true,
        virtual_text = {
          spacing = 4,
          source = "if_many",
          prefix = function(diagnostic)
            local icons = {
              [vim.diagnostic.severity.ERROR] = " ",
              [vim.diagnostic.severity.WARN] = " ",
              [vim.diagnostic.severity.INFO] = " ",
              [vim.diagnostic.severity.HINT] = " ",
            }
            return icons[diagnostic.severity] or "●"
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
      })

      -- Setup LSP servers
      local lspconfig = require("lspconfig")
      local capabilities = vim.lsp.protocol.make_client_capabilities()
      
      -- Enhanced capabilities from nvim-cmp if available
      local has_cmp, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
      if has_cmp then
        capabilities = cmp_nvim_lsp.default_capabilities(capabilities)
      end

      -- Setup gopls
      lspconfig.gopls.setup({
        capabilities = capabilities,
        settings = opts.servers.gopls.settings,
        on_attach = function(client, bufnr)
          -- Enable inlay hints
          if client.server_capabilities.inlayHintProvider then
            vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
          end

          -- Keymaps
          local bufopts = { noremap = true, silent = true, buffer = bufnr }
          vim.keymap.set("n", "gd", vim.lsp.buf.definition, bufopts)
          vim.keymap.set("n", "gr", vim.lsp.buf.references, bufopts)
          vim.keymap.set("n", "gi", vim.lsp.buf.implementation, bufopts)
          vim.keymap.set("n", "gt", vim.lsp.buf.type_definition, bufopts)
          vim.keymap.set("n", "K", vim.lsp.buf.hover, bufopts)
          vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, bufopts)
          vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, bufopts)
          vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, bufopts)
          vim.keymap.set("n", "]d", vim.diagnostic.goto_next, bufopts)
          vim.keymap.set("n", "<leader>e", vim.diagnostic.open_float, bufopts)
          vim.keymap.set("n", "<leader>q", vim.diagnostic.setloclist, bufopts)

          -- Format on save
          vim.api.nvim_create_autocmd("BufWritePre", {
            pattern = "*.go",
            callback = function()
              vim.lsp.buf.format({ async = false })
            end,
            group = vim.api.nvim_create_augroup("GoFormat", { clear = true }),
          })
        end,
      })

      -- Set faster update time for diagnostics
      vim.o.updatetime = 100
    end,
  },

  -- Mason to install gopls and tools
  {
    "williamboman/mason.nvim",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      vim.list_extend(opts.ensure_installed, {
        "gopls",
        "gofumpt",
        "goimports",
        "golangci-lint",
        "delve",
      })
    end,
  },

  -- Formatting with conform
  {
    "stevearc/conform.nvim",
    optional = true,
    opts = {
      formatters_by_ft = {
        go = { "goimports", "gofumpt" },
      },
    },
  },
}