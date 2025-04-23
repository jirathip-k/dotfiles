vim.keymap.set("n", "gd", vim.lsp.buf.definition, { desc = "Go to definition" })
vim.keymap.set("n", "gD", vim.lsp.buf.declaration, { desc = "Go to declaration" })

vim.lsp.enable({
	"luals",
	-- 'rust_analyzer',
	-- 'gopls',
	-- 'templ',
	"pyright",
	"ruff",
	-- 'tsserver',
	-- 'cssls',
	-- 'tailwindcss',
	-- 'html',
	-- 'htmx',
	-- 'emmet_ls',
})
