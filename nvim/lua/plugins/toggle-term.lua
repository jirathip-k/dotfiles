return {
	"akinsho/toggleterm.nvim",
	version = "*",
	config = function()
		local toggleterm = require("toggleterm")
		toggleterm.setup({
			open_mapping = [[<C-w>t]], -- 2<C-w>t for terminal no.2
			start_in_insert = true,
			insert_mappings = true,
		})

		local trim_spaces = true
		vim.keymap.set("v", "<leader>s", function()
			toggleterm.send_lines_to_terminal("single_line", trim_spaces, { args = vim.v.count })
		end, { desc = "Send Line to terminal", noremap = true, silent = true })

		vim.keymap.set("t", "<ESC>", "<C-\\><C-n>")
	end,
}
