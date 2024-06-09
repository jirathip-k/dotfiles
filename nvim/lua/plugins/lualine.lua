return {
	"nvim-lualine/lualine.nvim",
	dependencies = { "nvim-tree/nvim-web-devicons" },
	config = function()
		require("lualine").setup({
			options = { theme = "catppuccin" },
			sections = {
				lualine_a = { "mode" },
				lualine_b = { "branch", "diff", "diagnostics" },
				lualine_c = { "buffers" },
				lualine_x = { "filetype" },
				lualine_y = { "location" },
				lualine_z = { "os.date('%Y-%m-%d %H:%M:%S')" },
			},
		})
	end,
}
