return {
  {
    "akinsho/toggleterm.nvim",
    dependencies = { "nvim-lua/plenary.nvim", "nvim-telescope/telescope.nvim" },
    config = function()
      -- Image viewer function using Kitty remote control in floating terminal
      local function view_image_in_terminal(filepath)
        local Terminal = require("toggleterm.terminal").Terminal
        
        local image_viewer = Terminal:new({
          cmd = string.format(
            "kitten icat %s; echo ''; echo 'Press Enter to close...'; read",
            vim.fn.shellescape(filepath)
          ),
          direction = "float",
          close_on_exit = true,
          float_opts = {
            border = "curved",
            width = math.floor(vim.o.columns * 0.9),
            height = math.floor(vim.o.lines * 0.9),
            winblend = 3,
            title = " Image Preview - " .. vim.fn.fnamemodify(filepath, ":t") .. " ",
            title_pos = "center",
          },
          on_open = function(term)
            -- Make it easy to close
            vim.api.nvim_buf_set_keymap(
              term.bufnr,
              "n",
              "q",
              "<cmd>close<CR>",
              { noremap = true, silent = true }
            )
            vim.api.nvim_buf_set_keymap(
              term.bufnr,
              "n",
              "<Esc>",
              "<cmd>close<CR>",
              { noremap = true, silent = true }
            )
            vim.api.nvim_buf_set_keymap(
              term.bufnr,
              "t",
              "<C-c>",
              "<cmd>close<CR>",
              { noremap = true, silent = true }
            )
          end,
        })
        
        image_viewer:toggle()
      end

      -- Image finder function using telescope
      local function find_and_view_images()
        local telescope = require("telescope.builtin")
        local actions = require("telescope.actions")
        local action_state = require("telescope.actions.state")
        
        telescope.find_files({
          prompt_title = "Select Image to View",
          cwd = vim.fn.getcwd(),
          find_command = { 
            "rg", 
            "--files", 
            "--glob", "*.png", 
            "--glob", "*.jpg", 
            "--glob", "*.jpeg", 
            "--glob", "*.gif", 
            "--glob", "*.bmp", 
            "--glob", "*.webp", 
            "--glob", "*.svg", 
            "--glob", "*.ico", 
            "--glob", "*.tiff", 
            "--glob", "*.tif" 
          },
          attach_mappings = function(prompt_bufnr, map)
            actions.select_default:replace(function()
              actions.close(prompt_bufnr)
              local selection = action_state.get_selected_entry()
              if selection then
                local file_path = selection[1]
                view_image_in_terminal(file_path)
              end
            end)
            return true
          end,
        })
      end

      -- Setup module
      local M = {}
      
      M.config = {
        image_extensions = { "png", "jpg", "jpeg", "gif", "bmp", "webp", "svg", "ico", "tiff", "tif" },
      }

      function M.setup(opts)
        M.config = vim.tbl_extend("force", M.config, opts or {})
      end

      -- Create user commands
      vim.api.nvim_create_user_command("ImageFinder", function()
        find_and_view_images()
      end, {
        desc = "Find and view images with fuzzy finder",
      })

      vim.api.nvim_create_user_command("KittyImage", function(opts)
        local filepath = opts.args ~= "" and opts.args or vim.fn.expand("%:p")
        if vim.fn.filereadable(filepath) == 1 then
          view_image_in_terminal(filepath)
        else
          vim.notify("File not found: " .. filepath, vim.log.levels.ERROR)
        end
      end, {
        nargs = "?",
        complete = "file",
        desc = "View image with Kitty",
      })

      -- Setup with default config
      M.setup({})
      
      -- Add keymap for image fuzzy finder (similar to <leader>tj)
      vim.keymap.set("n", "<leader>oi", function()
        find_and_view_images()
      end, { desc = "Open image with fuzzy finder" })

      -- Add keymap for manual image viewing of current file
      vim.keymap.set("n", "<leader>vi", function()
        local filepath = vim.fn.expand("%:p")
        local extension = vim.fn.expand("%:e"):lower()
        
        if vim.tbl_contains(M.config.image_extensions, extension) then
          view_image_in_terminal(filepath)
        else
          -- Try to view file under cursor
          local file_under_cursor = vim.fn.expand("<cfile>")
          if vim.fn.filereadable(file_under_cursor) == 1 then
            view_image_in_terminal(file_under_cursor)
          else
            vim.notify("No image file found", vim.log.levels.WARN)
          end
        end
      end, { desc = "View image with Kitty" })
    end,
  },
}