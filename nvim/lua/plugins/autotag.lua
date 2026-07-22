-- Auto close/rename HTML/JSX/TSX tags (replaces nvim-treesitter's removed autotag module).
return {
	"windwp/nvim-ts-autotag",
	ft = {
		"html",
		"javascript",
		"javascriptreact",
		"typescript",
		"typescriptreact",
		"tsx",
		"jsx",
		"vue",
		"svelte",
		"astro",
		"markdown",
		"xml",
	},
	opts = {},
}
