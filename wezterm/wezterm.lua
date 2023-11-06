local wezterm = require 'wezterm'

local config = {}

if wezterm.config_builder then
    config = wezterm.config_builder()
end


config.window_decorations = "NONE"
config.initial_rows = 40
config.use_fancy_tab_bar = false
config.color_scheme = 'Catppuccin Frappe'
config.window_background_opacity = 0.9
config.tab_bar_at_bottom = true
config.window_padding = {
    left = 50,
    right = 50,
    top = 50,
    bottom = 20,
}



return config
