return {
	"nvim-telescope/telescope.nvim",
	tag = "0.1.4",
	dependencies = {
		"nvim-lua/plenary.nvim",
		"debugloop/telescope-undo.nvim",
	},
	config = function()
		require("telescope").setup({
			extensions = {
				undo = {},
			},
		})

		require("telescope").load_extension("undo")
	end,
}
