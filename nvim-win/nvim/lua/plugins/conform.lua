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
				yaml = { "prettier" },
				markdown = { "prettier" },
				lua = { "stylua" },
				python = { "ruff_format" },
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
					command = "cmd.exe",
					args = {
						"/C",
						"C:\\Users\\yt601195\\.pyenv\\pyenv-win\\shims\\ruff",
						"format",
						"-",
					},
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
