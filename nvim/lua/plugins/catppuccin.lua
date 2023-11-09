return {
	"catppuccin/nvim",
	name = "catppuccin",
	priority = 1000,
	config = function()
		-- The setup function
		local setup = function()
			require("catppuccin").setup({
				flavour = "mocha", -- latte, frappe, macchiato, mocha
				transparent_background = true,
				integrations = {
					nvimtree = true,
					treesitter = true,
					telescope = true,
					which_key = true,
					cmp = true,
				},
				custom_highlights = function(colors)
					return {
						LineNr = { fg = colors.overlay2 },
						CursorLineNr = { fg = colors.mauve },
						CursorLine = { bg = colors.none },
					}
				end,
			})

			vim.cmd.colorscheme("catppuccin")
		end

		setup()
	end,
}
