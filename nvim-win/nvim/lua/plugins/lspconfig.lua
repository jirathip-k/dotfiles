return {
	"neovim/nvim-lspconfig",
	event = { "BufReadPre", "BufNewFile" },
	dependencies = {
		"hrsh7th/cmp-nvim-lsp",
	},
	config = function()
		local lspconfig = require("lspconfig")
		local configs = require("lspconfig/configs")
		local cmp_nvim_lsp = require("cmp_nvim_lsp")
		local opts = { noremap = true, silent = true }
		local on_attach = function(_, bufnr)
			opts.buffer = bufnr

			opts.desc = "Show LSP Reference"
			vim.keymap.set("n", "gr", "<cmd>Telescope lsp_references<CR>", opts)

			opts.desc = "Go Declaration"
			vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts)

			opts.desc = "Go Definition"
			vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)

			opts.desc = "Show Documentation"
			vim.keymap.set("n", "<leader>D", vim.lsp.buf.hover, opts)

			opts.desc = "Code Action"
			vim.keymap.set("n", "<leader>C", vim.lsp.buf.code_action, opts)

			opts.desc = "Rename"
			vim.keymap.set("n", "<leader>r", vim.lsp.buf.rename, opts)

			opts.desc = "Restart LSP"
			vim.keymap.set("n", "<leader>L", ":LspRestart<CR>", opts)
		end

		local capabilities = cmp_nvim_lsp.default_capabilities()
		local util = require("lspconfig.util")

		local path = util.path

		local function get_python_path(workspace)
			-- Use activated virtualenv.
			if vim.env.VIRTUAL_ENV then
				return path.join(vim.env.VIRTUAL_ENV, "Scripts", "python")
			end

			-- Find and use virtualenv in workspace directory.
			for _, pattern in ipairs({ "*", ".*" }) do
				local match = vim.fn.glob(path.join(workspace, "poetry.lock"))
				if match ~= "" then
					local venv = vim.fn.trim(vim.fn.system("poetry --directory " .. workspace .. " env info -p"))
					return path.join(venv, "Scripts", "python")
				end
			end
		end
		vim.api.nvim_create_user_command("GetPoetryPath", get_python_path, { nargs = "?" })

		lspconfig["lua_ls"].setup({
			capabilities = capabilities,
			on_attach = on_attach,
			settings = {
				Lua = {
					diagnostics = {
						globals = { "vim" },
					},
					workspace = {
						library = {
							[vim.fn.expand("$VIMRUNTIME/lua")] = true,
							[vim.fn.stdpath("config") .. "/lua"] = true,
						},
					},
					hint = { enable = true },
				},
			},
		})
		lspconfig["rust_analyzer"].setup({
			capabilities = capabilities,
			on_attach = on_attach,
		})

		lspconfig["gopls"].setup({
			capabilities = capabilities,
			on_attach = on_attach,
			filetypes = { "go", "templ" },
		})

		lspconfig["templ"].setup({
			capabilities = capabilities,
			on_attach = on_attach,
		})

		lspconfig["ruff_lsp"].setup({
			cmd = {
				"cmd.exe",
				"/C",
				"C:\\Users\\yt601195\\.pyenv\\pyenv-win\\shims\\ruff",
				"server",
			},
			capabilities = capabilities,
			on_attach = on_attach,
		})

		lspconfig["pyright"].setup({
			cmd = { "cmd.exe", "/C", "C:\\Users\\yt601195\\.pyenv\\pyenv-win\\shims\\pyright-langserver", "--stdio" },
			capabilities = capabilities,
			on_attach = on_attach,
			on_init = function(client)
				client.config.settings.python.pythonPath = get_python_path(client.config.root_dir)
			end,
		})

		lspconfig["tsserver"].setup({
			capabilities = capabilities,
			on_attach = on_attach,
		})

		lspconfig["cssls"].setup({
			capabilities = capabilities,
			on_attach = on_attach,
		})
		lspconfig["tailwindcss"].setup({
			capabilities = capabilities,
			on_attach = on_attach,
		})

		lspconfig["html"].setup({
			capabilities = capabilities,
			on_attach = on_attach,
			filetypes = { "html", "templ" },
		})

		lspconfig["htmx"].setup({
			on_attach = on_attach,
			capabilities = capabilities,
			filetypes = { "html", "templ" },
		})

		lspconfig["emmet_ls"].setup({
			capabilities = capabilities,
			on_attach = on_attach,
			filetypes = {
				"css",
				"eruby",
				"html",
				"javascript",
				"javascriptreact",
				"less",
				"sass",
				"scss",
				"svelte",
				"pug",
				"typescriptreact",
				"vue",
			},
		})
	end,
}
