local wezterm = require("wezterm")
local config = wezterm.config_builder()

-- Fonts
config.font_size = 12

-- Window
config.color_scheme = "Catppuccin Mocha"
config.window_background_opacity = 0.8

-- Windows OS
local is_windows_os = function()
	return wezterm.target_triple:find("windows") ~= nil
end
if is_windows_os() then
	config.default_domain = "WSL:Ubuntu"
end

return config
