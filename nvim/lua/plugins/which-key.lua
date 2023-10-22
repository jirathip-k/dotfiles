return {
	"folke/which-key.nvim",
	event = "VeryLazy",
	init = function()
		vim.o.timeout = true
		vim.o.timeoutlen = 300
	end,
	config = function()
		local wk = require("which-key")

		local mappings = {
			["<leader>f"] = {
				name = "Telescope Fuzzy Finder", -- subgroup
			},
			["<leader> "] = { "<cmd>:TSBufEnable highlight<cr>", "Select Node" },
		}

		-- Register your mappings with which-key
		wk.register(mappings, { noremap = true, silent = true })

		wk.setup({
			layout = {
				height = { min = 1, max = 5 }, -- set max height to 2
				width = { min = 20, max = 50 }, -- keep this as is, or adjust to your preference
				spacing = 3,
				align = "center",
			},
		})
	end,
}
