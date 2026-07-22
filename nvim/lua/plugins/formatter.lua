return {
	"stevearc/conform.nvim",
	event = { "BufReadPre", "BufNewFile" },
	config = function()
		local conform = require("conform")
		conform.setup({
			formatters_by_ft = {
				javascript = { "prettier" },
				typescript = { "prettier" },
				javascriptreact = { "prettier" },
				typescriptreact = { "prettier" },
				css = { "prettier" },
				html = { "prettier" },
				json = { "prettier" },
				jsonc = { "prettier" },
				yaml = { "prettier" },
				markdown = { "prettier" },
				lua = { "stylua" },
				python = { "ruff_format" },
				swift = { "swift_format" },
				sql = { "sql_formatter" },
				["*"] = { "injected" },
			},
			format_on_save = {
				lsp_fallback = false,
				async = false,
				timeout_ms = 500,
			},
			formatters = {
				ruff_format = {
					command = "ruff",
					args = { "format", "-" },
					stdin = true,
				},
				-- swift-format ships with Xcode; reach it via xcrun (not on PATH).
				swift_format = {
					command = "xcrun",
					args = { "swift-format", "format", "-" },
					stdin = true,
				},
			},
		})

		vim.keymap.set({ "n", "v" }, "<leader>m", function()
			conform.format({
				lsp_fallback = false,
				async = false,
				timeout_ms = 500,
			})
		end, { desc = "Format Code" })
	end,
}
