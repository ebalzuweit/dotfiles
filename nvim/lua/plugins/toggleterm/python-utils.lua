-- Python virtual environment utilities for toggleterm
local M = {}

-- Function to find virtual environment in current directory and parents
function M.find_venv()
    local cwd = vim.fn.getcwd()
    local venv_paths = {}
    
    -- Common virtual environment directory names
    local venv_names = {
        "venv",
        ".venv", 
        "env",
        ".env",
        "virtualenv",
        ".virtualenv"
    }
    
    -- Search in current directory and parent directories
    local search_dir = cwd
    for _ = 1, 5 do -- Limit search to 5 levels up
        for _, venv_name in ipairs(venv_names) do
            local venv_path = search_dir .. "/" .. venv_name
            local activate_script = venv_path .. "/bin/activate"
            
            -- Check if virtual environment exists
            if vim.fn.isdirectory(venv_path) == 1 and vim.fn.filereadable(activate_script) == 1 then
                table.insert(venv_paths, {
                    name = venv_name,
                    path = venv_path,
                    activate_script = activate_script,
                    level = string.rep("../", vim.tbl_count(vim.split(vim.fn.fnamemodify(search_dir, ":~:."), "/", { plain = true })) - vim.tbl_count(vim.split(vim.fn.fnamemodify(cwd, ":~:."), "/", { plain = true })))
                })
            end
        end
        
        -- Move up one directory
        local parent = vim.fn.fnamemodify(search_dir, ":h")
        if parent == search_dir then
            break -- Reached root
        end
        search_dir = parent
    end
    
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

-- Function to show venv selection menu if multiple found
function M.select_venv(venv_list, callback)
    if #venv_list == 0 then
        callback(nil)
        return
    elseif #venv_list == 1 then
        callback(venv_list[1])
        return
    end
    
    -- Create selection menu
    local items = {}
    for i, venv in ipairs(venv_list) do
        local display_path = venv.level ~= "" and (venv.level .. venv.name) or venv.name
        table.insert(items, string.format("%d. %s (%s)", i, venv.name, display_path))
    end
    table.insert(items, string.format("%d. None (no virtual environment)", #venv_list + 1))
    
    vim.ui.select(items, {
        prompt = "Select Python virtual environment:",
        format_item = function(item)
            return item
        end,
    }, function(choice, idx)
        if not choice or idx == #items then
            callback(nil)
        else
            callback(venv_list[idx])
        end
    end)
end

return M