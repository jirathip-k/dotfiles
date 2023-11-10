return {
	"folke/which-key.nvim",
	event = "VeryLazy",
	init = function()
		vim.o.timeout = true
		vim.o.timeoutlen = 300
	end,
	config = function()
		local wk = require("which-key")

		wk.setup({
			layout = {
				height = { min = 1, max = 10 },
				width = { min = 20, max = 50 },
				spacing = 4,
				align = "center",
			},
			plugins = {
				presets = {
					operators = false,
				},
			},
		})
	end,
}
