return {
	"nvim-treesitter/nvim-treesitter-textobjects",
	lazy = true,
	config = function()
		local tree = require("nvim-treesitter.configs")
		tree.setup({
			textobjects = {
				select = {
					enable = true,
					lookahead = true,
					keymaps = {
						["of"] = { query = "@function.outer", desc = "Select outer function" },
						["if"] = { query = "@function.inner", desc = "Select inner function" },
						["oc"] = { query = "@conditional.outer", desc = "Select outer conditional" },
						["ic"] = { query = "@conditional.inner", desc = "Select inner conditional" },
						["ol"] = { query = "@loop.outer", desc = "Select outer loop" },
						["il"] = { query = "@loop.inner", desc = "Select inner loop" },
					},
				},
				move = {
					enable = true,
					set_jumps = true,
					goto_next_start = {
						["]="] = { query = "@assignment.inner", desc = "Go to next assignment" },
						["]p"] = { query = "@parameter.inner", desc = "Go to next parameter" },
						["]f"] = { query = "@function.outer", desc = "Go to next function" },
						["]c"] = { query = "@class.outer", desc = "Go to next class" },
					},
					goto_previous_start = {
						["[="] = { query = "@assignment.inner", desc = "Go to prev assignment" },
						["[p"] = { query = "@parameter.inner", desc = "Go to prev parameter" },
						["[f"] = { query = "@function.outer", desc = "Go to prev function" },
						["[c"] = { query = "@class.outer", desc = "Go to prev class" },
					},
				},
				swap = {
					enable = true,
					swap_next = {
						["snp"] = { query = "@parameter.inner", desc = "Swap next parameter" },
						["snf"] = { quey = "@function.outer", desc = "Swap next function" },
					},
					swap_previous = {
						["spp"] = { query = "@parameter.inner", desc = "Swap prev parameter" },
						["spf"] = { quey = "@function.outer", desc = "Swap prev function" },
					},
				},
			},
		})
	end,
}
