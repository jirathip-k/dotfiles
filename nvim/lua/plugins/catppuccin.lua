return {
	"catppuccin/nvim",
	name = "catppuccin",
	priority = 1000,
	config = function()
		-- The setup function
		local setup = function()
			require("catppuccin").setup({
				flavour = "mocha", -- latte, frappe, macchiato, mocha
				transparent_background = true, -- disables setting the background color.
				integrations = {
					nvimtree = true,
					treesitter = true,
					telescope = true,
				},
			})

			-- setup must be called before loading
			vim.cmd.colorscheme("catppuccin")
		end

		-- Call the setup function
		setup()
	end,
}
