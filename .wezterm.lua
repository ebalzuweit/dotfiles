local wezterm = require("wezterm")
local config = wezterm.config_builder()

-- Function to extract the last part of a path
local function basename(s)
	local pattern = "^(.*)[/\\](.*)$"
	local base = string.gsub(s, pattern, "%2")
	if base == nil or base == "" then
		base = string.gsub(s, pattern, "%1")
		return basename(base)
	else
		return base
	end
end

local function replace_home_in_path(path)
	local home = os.getenv("HOME") or os.getenv("USERPROFILE")
	if home and path and string.sub(path, 1, #home) == home then
		return "~" .. string.sub(path, #home + 1)
	end
	return path
end

local is_windows_os = function()
	return wezterm.target_triple:find("windows") ~= nil
end

-- Fonts
config.font_size = 12
config.font = wezterm.font_with_fallback {
	'JetBrainsMono Nerd Font',
	'JetBrains Mono'
}

-- Window
config.color_scheme = "Catppuccin Mocha"
config.window_background_opacity = 0.8

-- Windows OS
if is_windows_os() then
	-- Default to WSL (Ubuntu)
	config.default_domain = "WSL:Ubuntu"
end

wezterm.on("format-tab-title", function(tab, tabs, panes, config, hover, max_width)
	local pane = tab.active_pane
	local cwd = pane.current_working_dir

	-- Extract the last directory name from the full path
	local dir = ""
	if cwd then
		if cwd.file_path then
			local path = replace_home_in_path(cwd.file_path)
			dir = basename(path)
		else
			local path = replace_home_in_path(cwd)
			dir = basename(path)
		end
	end

	-- Format: "directory/ process"
	local title = string.format("%s/ %s", dir, pane.title)

	-- Truncate if too long
	if #title > max_width - 2 then
		title = title:sub(1, max_width - 5) .. "..."
	end

	return {
		{ Text = " " .. title .. " " },
	}
end)

return config
