return {
	"nvim-treesitter/nvim-treesitter",
	build = ":TSUpdate",
	event = { "BufReadPre", "BufNewFile" },
	dependencies = {
		"nvim-treesitter/nvim-treesitter-textobjects",
	},
	config = function()
		local configs = require("nvim-treesitter.configs")

		configs.setup({
			ensure_installed = {
				"python",
				"rust",
				"lua",
				"sql",
				"toml",
				"yaml",
				"markdown",
				"latex",
				"json",
				"vim",
				"csv",
				"vimdoc",
				"typescript",
				"javascript",
				"html",
				"css",
				"tsx",
				"bash",
				"fish",
			},
			sync_install = false,
			highlight = { enable = true },
			indent = { enable = true },
			incremental_selection = {
				enable = true,
				keymaps = {
					init_selection = "e",
					node_incremental = "e",
				},
			},
		})
	end,
}
