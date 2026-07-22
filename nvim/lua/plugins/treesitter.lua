return {
  'nvim-treesitter/nvim-treesitter',
  lazy = false,
  build = ':TSUpdate',
  config = function()
local configs = require("nvim-treesitter.config")
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
			autotag = { enable = true },
			incremental_selection = {
				enable = true,
				keymaps = {
					init_selection = "e",
					node_incremental = "e",
				},
			},
        })
end
}
