return {
  -- Enhanced Go development with proper linting
  {
    "neovim/nvim-lspconfig",
    opts = {
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
              analyses = {
                unusedparams = true,
                shadow = true,
                fieldalignment = true,
                nilness = true,
                unusedwrite = true,
                useany = true,
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
            },
          },
        },
      },
    },
  },


  -- Ensure Mason installs the necessary tools
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

  -- Configure conform for Go formatting
  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = {
        go = { "goimports", "gofumpt" },
      },
    },
  },

  -- Additional Go-specific tools
  {
    "ray-x/go.nvim",
    dependencies = {
      "ray-x/guihua.lua",
      "neovim/nvim-lspconfig",
      "nvim-treesitter/nvim-treesitter",
    },
    config = function()
      require("go").setup({
        goimports = "gopls",
        gofmt = "gopls",
        tag_transform = false,
        test_dir = "",
        comment_placeholder = " ",
        lsp_cfg = false, -- We're using LazyVim's LSP setup
        lsp_gofumpt = true,
        dap_debug = true,
        dap_debug_keymap = false,
        dap_debug_gui = false,
        dap_debug_vt = false,
        build_tags = "tag1,tag2",
        textobjects = true,
        test_runner = "go",
        verbose_tests = true,
        run_in_floaterm = false,
        trouble = true,
        test_efm = false,
        luasnip = false, -- Disable LuaSnip integration
        iferr_vertical_shift = 4,
      })

      -- Format on save
      local format_sync_grp = vim.api.nvim_create_augroup("GoFormat", {})
      vim.api.nvim_create_autocmd("BufWritePre", {
        pattern = "*.go",
        callback = function()
          require("go.format").goimports()
        end,
        group = format_sync_grp,
      })
    end,
    event = { "CmdlineEnter" },
    ft = { "go", "gomod" },
    build = ':lua require("go.install").update_all_sync()',
  },

  -- Ensure golangci-lint works properly
  {
    "jose-elias-alvarez/null-ls.nvim",
    optional = true,
    opts = function(_, opts)
      local nls = require("null-ls")
      opts.sources = opts.sources or {}
      table.insert(opts.sources, nls.builtins.diagnostics.golangci_lint)
    end,
  },
}