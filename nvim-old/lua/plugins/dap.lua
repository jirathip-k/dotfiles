return {
	"mfussenegger/nvim-dap-python",
	ft = "python",
	dependencies = {
		"rcarriga/nvim-dap-ui",
		"nvim-neotest/nvim-nio",
		"theHamsta/nvim-dap-virtual-text",
		"mfussenegger/nvim-dap",
	},
	config = function()
		local dap = require("dap")
		local ui = require("dapui")
		local path = "~/.local/share/nvim/mason/packages/debugpy/venv/bin/python"

		require("dapui").setup()
		require("nvim-dap-virtual-text").setup()
		require("dap-python").setup(path)

		vim.keymap.set(
			"n",
			"<leader>db",
			dap.toggle_breakpoint,
			{ desc = "Toggle breakpoint", noremap = true, silent = true }
		)
		vim.keymap.set("n", "<leader>dr", dap.run_to_cursor, { desc = "Run to cursor", noremap = true, silent = true })

		vim.keymap.set("n", "<leader>d?", function()
			require("dapui").eval(nil, { enter = true })
		end, { desc = "Eval var under cursor", noremap = true, silent = true })

		vim.keymap.set("n", "<leader>dc", dap.continue, { desc = "Continue", noremap = true, silent = true })
		-- vim.keymap.set("n", "<leader>b2", dap.step_into, { desc = "Step into", noremap = true, silent = true })
		-- vim.keymap.set("n", "<leader>b3", dap.step_over, { desc = "Step over", noremap = true, silent = true })
		-- vim.keymap.set("n", "<leader>b4", dap.step_out, { desc = "Step out", noremap = true, silent = true })
		-- vim.keymap.set("n", "<leader>b5", dap.step_back, { desc = "Step back", noremap = true, silent = true })
		vim.keymap.set("n", "<leader>ds", dap.restart, { desc = "Restart", noremap = true, silent = true })
		dap.listeners.before.attach.dapui_config = function()
			ui.open()
		end
		dap.listeners.before.launch.dapui_config = function()
			ui.open()
		end
		dap.listeners.before.event_terminated.dapui_config = function()
			ui.close()
		end
		dap.listeners.before.event_exited.dapui_config = function()
			ui.close()
		end
	end,
}
