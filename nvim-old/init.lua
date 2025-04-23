require("lazy-plugins-manager")
require("setting")
require("keymap")

if vim.g.neovide then
	vim.o.guifont = "JetBrainsMono Nerd Font:h13"
	vim.g.neovide_padding_top = 50
	vim.g.neovide_padding_bottom = 50
	vim.g.neovide_padding_right = 50
	vim.g.neovide_padding_left = 50
	vim.g.neovide_transparency = 0.8
	vim.api.nvim_set_hl(0, "Normal", { bg = "#232634" })
end
