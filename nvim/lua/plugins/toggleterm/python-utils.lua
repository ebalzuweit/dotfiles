-- Python virtual environment utilities for toggleterm
local M = {}

-- Function to recursively find all virtual environments in a directory
local function find_venv_recursive(dir, base_dir, venv_paths, depth)
    if depth > 10 then return end -- Limit recursion depth
    
    local handle = vim.loop.fs_scandir(dir)
    if not handle then return end
    
    while true do
        local name, type = vim.loop.fs_scandir_next(handle)
        if not name then break end
        
        -- Skip hidden directories (except .venv), node_modules, and other common non-venv dirs
        if type == "directory" and name ~= "node_modules" and name ~= "__pycache__" and name ~= ".git" then
            if name ~= ".venv" and name:sub(1, 1) == "." then
                -- Skip other hidden directories
                goto continue
            end
            
            local full_path = dir .. "/" .. name
            local activate_script = full_path .. "/bin/activate"
            local pyvenv_cfg = full_path .. "/pyvenv.cfg"
            
            -- Check if this is a virtual environment
            if vim.fn.filereadable(activate_script) == 1 or vim.fn.filereadable(pyvenv_cfg) == 1 then
                -- Calculate relative path from base directory
                local relative_path = vim.fn.fnamemodify(full_path, ":~:.")
                if base_dir and base_dir ~= "" then
                    relative_path = full_path:gsub("^" .. vim.pesc(base_dir) .. "/", "")
                end
                
                table.insert(venv_paths, {
                    name = name,
                    path = full_path,
                    activate_script = activate_script,
                    relative_path = relative_path,
                    parent_dir = dir
                })
            else
                -- Recursively search subdirectories
                find_venv_recursive(full_path, base_dir, venv_paths, depth + 1)
            end
        end
        
        ::continue::
    end
end

-- Function to find ALL virtual environments in the repository
function M.find_all_venvs()
    local cwd = vim.fn.getcwd()
    local venv_paths = {}
    
    -- Find all venvs recursively from current directory
    find_venv_recursive(cwd, cwd, venv_paths, 0)
    
    return venv_paths
end

-- Function to get activation command for virtual environment
function M.get_venv_activation_cmd(venv_info)
    if not venv_info then
        return nil
    end
    
    return string.format("source %s", vim.fn.shellescape(venv_info.activate_script))
end

-- Function to create terminal command with venv activation
function M.create_python_terminal_cmd(venv_info)
    local base_shell = vim.o.shell
    
    if venv_info then
        -- Create command that activates venv and then starts shell
        local activate_cmd = M.get_venv_activation_cmd(venv_info)
        return string.format('%s -c "%s && exec %s"', base_shell, activate_cmd, base_shell)
    else
        return base_shell
    end
end

-- Function to detect if a name suggests Python environment
function M.is_python_name(name)
    if not name or name == "" then
        return false
    end
    
    local python_indicators = {
        "py",
        "python",
        "python3",
        "pip",
        "venv",
        "virtualenv",
        "conda",
        "poetry"
    }
    
    local lower_name = string.lower(name)
    for _, indicator in ipairs(python_indicators) do
        if lower_name == indicator or lower_name:find(indicator) then
            return true
        end
    end
    
    return false
end

-- Function to detect if a name suggests Go environment
function M.is_go_name(name)
    if not name or name == "" then
        return false
    end
    
    local go_indicators = {
        "go",
        "golang",
        "gopher"
    }
    
    local lower_name = string.lower(name)
    for _, indicator in ipairs(go_indicators) do
        if lower_name == indicator then
            return true
        end
    end
    
    return false
end

-- Function to recursively find all go.mod files in a directory
local function find_go_mod_recursive(dir, base_dir, go_mod_paths, depth)
    if depth > 10 then return end -- Limit recursion depth
    
    local handle = vim.loop.fs_scandir(dir)
    if not handle then return end
    
    while true do
        local name, type = vim.loop.fs_scandir_next(handle)
        if not name then break end
        
        if name == "go.mod" and type == "file" then
            -- Calculate relative path from base directory
            local relative_path = vim.fn.fnamemodify(dir, ":~:.")
            if base_dir and base_dir ~= "" then
                relative_path = dir:gsub("^" .. vim.pesc(base_dir) .. "/", "")
            end
            
            table.insert(go_mod_paths, {
                name = "go.mod",
                path = dir .. "/go.mod",
                directory = dir,
                relative_path = relative_path == "." and "./" or relative_path
            })
        elseif type == "directory" and name ~= "node_modules" and name ~= ".git" and name ~= "vendor" then
            -- Skip hidden directories and common non-Go dirs
            if name:sub(1, 1) ~= "." then
                find_go_mod_recursive(dir .. "/" .. name, base_dir, go_mod_paths, depth + 1)
            end
        end
    end
end

-- Function to find ALL go.mod files in the repository
function M.find_all_go_mods()
    local cwd = vim.fn.getcwd()
    local go_mod_paths = {}
    
    -- Find all go.mod files recursively from current directory
    find_go_mod_recursive(cwd, cwd, go_mod_paths, 0)
    
    return go_mod_paths
end

-- Function to show go.mod selection with telescope fuzzy finder
function M.select_go_mod_with_telescope(go_mod_list, callback)
    if #go_mod_list == 0 then
        vim.notify("No go.mod files found in this repository", vim.log.levels.WARN)
        callback(nil)
        return
    elseif #go_mod_list == 1 then
        -- Only one go.mod found, use it and notify
        vim.notify("Defaulting to: " .. go_mod_list[1].relative_path, vim.log.levels.INFO)
        callback(go_mod_list[1])
        return
    end
    
    -- Multiple go.mod files found, use telescope for selection
    local pickers = require("telescope.pickers")
    local finders = require("telescope.finders")
    local conf = require("telescope.config").values
    local actions = require("telescope.actions")
    local action_state = require("telescope.actions.state")
    
    -- Add a "None" option
    local items = vim.deepcopy(go_mod_list)
    table.insert(items, { name = "None", relative_path = "No Go module", directory = nil })
    
    pickers.new({}, {
        prompt_title = "Select Go Module",
        finder = finders.new_table({
            results = items,
            entry_maker = function(entry)
                return {
                    value = entry,
                    display = entry.relative_path or entry.name,
                    ordinal = entry.relative_path or entry.name,
                }
            end,
        }),
        sorter = conf.generic_sorter({}),
        attach_mappings = function(prompt_bufnr, map)
            actions.select_default:replace(function()
                actions.close(prompt_bufnr)
                local selection = action_state.get_selected_entry()
                if selection and selection.value.directory then
                    callback(selection.value)
                else
                    callback(nil)
                end
            end)
            return true
        end,
    }):find()
end

-- Function to show venv selection with telescope fuzzy finder
function M.select_venv_with_telescope(venv_list, callback)
    if #venv_list == 0 then
        vim.notify("No Python virtual environments found in this repository", vim.log.levels.WARN)
        callback(nil)
        return
    elseif #venv_list == 1 then
        -- Only one venv found, use it and notify
        vim.notify("Defaulting to: " .. venv_list[1].relative_path, vim.log.levels.INFO)
        callback(venv_list[1])
        return
    end
    
    -- Multiple venvs found, use telescope for selection
    local pickers = require("telescope.pickers")
    local finders = require("telescope.finders")
    local conf = require("telescope.config").values
    local actions = require("telescope.actions")
    local action_state = require("telescope.actions.state")
    
    -- Add a "None" option
    local items = vim.deepcopy(venv_list)
    table.insert(items, { name = "None", relative_path = "No virtual environment", path = nil })
    
    pickers.new({}, {
        prompt_title = "Select Python Virtual Environment",
        finder = finders.new_table({
            results = items,
            entry_maker = function(entry)
                return {
                    value = entry,
                    display = entry.relative_path or entry.name,
                    ordinal = entry.relative_path or entry.name,
                }
            end,
        }),
        sorter = conf.generic_sorter({}),
        attach_mappings = function(prompt_bufnr, map)
            actions.select_default:replace(function()
                actions.close(prompt_bufnr)
                local selection = action_state.get_selected_entry()
                if selection and selection.value.path then
                    callback(selection.value)
                else
                    callback(nil)
                end
            end)
            return true
        end,
    }):find()
end

return M