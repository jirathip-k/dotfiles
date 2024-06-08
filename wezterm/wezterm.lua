local wezterm = require("wezterm")
local mux = wezterm.mux
local config = {}
if wezterm.config_builder then
    config = wezterm.config_builder()
end

wezterm.on("gui-startup", function()
    local tab, pane, window = mux.spawn_window({})
    window:gui_window():maximize()
end)

config.font_size = 14
config.window_decorations = "NONE"
config.enable_wayland = false
config.front_end = "WebGpu"

--config.initial_rows = 40
config.use_fancy_tab_bar = false
config.color_scheme = "Catppuccin Frappe"
config.window_background_opacity = 0.9
config.tab_bar_at_bottom = true
config.window_padding = {
    left = 50,
    right = 50,
    top = 50,
    bottom = 20,
}
local act = wezterm.action

config.keys = {}
for i = 1, 8 do
    table.insert(config.keys, {
        key = tostring(i),
        mods = 'ALT',
        action = act.ActivateTab(i - 1),
    })
end
table.insert(config.keys, {
    key = 't',
    mods = 'ALT',
    action = act.SpawnTab("CurrentPaneDomain")
})

table.insert(config.keys, {
    key = 't',
    mods = 'SUPER',
    action = act.DisableDefaultAssignment
})

return config
