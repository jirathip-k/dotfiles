return {
	"nvim-lualine/lualine.nvim",
	dependencies = { "nvim-tree/nvim-web-devicons", "catppuccin/nvim" },
	config = function()
		require("lualine").setup({
			-- catppuccin renamed its lualine themes; use the flavour-specific one.
			options = { theme = "catppuccin-frappe" },
			sections = {
				lualine_a = { "mode" },
				lualine_b = { "branch", "diff", "diagnostics" },
				lualine_c = { "buffers" },
				lualine_x = { "filetype" },
				lualine_y = { "location" },
				lualine_z = {
					{ function() return os.date("%Y-%m-%d %H:%M:%S") end },
				},
			},
		})
	end,
}
