-- Give every server blink.cmp's completion capabilities (snippets, etc.).
vim.lsp.config("*", {
	capabilities = require("blink.cmp").get_lsp_capabilities(),
})

vim.lsp.enable({
	"luals",
	"pyright",
	"ruff",
	"tsserver",
	"tailwindcss",
	"sourcekit", -- Swift / Objective-C
	-- 'rust_analyzer',
	-- 'gopls',
})

-- Buffer-local keymaps + features once a server attaches.
vim.api.nvim_create_autocmd("LspAttach", {
	desc = "LSP keymaps",
	callback = function(args)
		local bufnr = args.buf
		local client = vim.lsp.get_client_by_id(args.data.client_id)
		local map = function(mode, lhs, rhs, desc)
			vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc })
		end

		map("n", "gd", vim.lsp.buf.definition, "Go to definition")
		map("n", "gD", vim.lsp.buf.declaration, "Go to declaration")
		map("n", "gi", vim.lsp.buf.implementation, "Go to implementation")
		map("n", "gy", vim.lsp.buf.type_definition, "Go to type definition")
		map("n", "K", vim.lsp.buf.hover, "Hover docs")
		map("n", "<leader>rn", vim.lsp.buf.rename, "Rename symbol")
		map({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, "Code action")
		map("n", "<leader>d", vim.diagnostic.open_float, "Line diagnostics")
		map("n", "[d", function() vim.diagnostic.jump({ count = -1 }) end, "Prev diagnostic")
		map("n", "]d", function() vim.diagnostic.jump({ count = 1 }) end, "Next diagnostic")

		-- Inlay hints (TypeScript, Swift, Lua, ...) — toggle with <leader>th.
		if client and client:supports_method("textDocument/inlayHint") then
			vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
			map("n", "<leader>th", function()
				vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = bufnr }), { bufnr = bufnr })
			end, "Toggle inlay hints")
		end
	end,
})
