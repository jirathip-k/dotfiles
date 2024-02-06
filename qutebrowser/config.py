config.load_autoconfig()


config.set("colors.webpage.darkmode.enabled", True)
config.bind(",m", "spawn mpv {url}")
config.bind("<CTRL-f>", "hint links spawn mpv {hint-url}")
