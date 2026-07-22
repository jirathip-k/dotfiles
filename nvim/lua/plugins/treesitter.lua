return {
	"nvim-treesitter/nvim-treesitter",
	branch = "master", -- classic API (ensure_installed/highlight/indent). Pin so it doesn't jump to the `main` rewrite.
	lazy = false,
	build = ":TSUpdate",
	config = function()
		require("nvim-treesitter.configs").setup({
			-- NOTE: `swift` is intentionally NOT here. On Neovim's ABI 15 the master
			-- branch can't auto-generate grammars that ship only a grammar.js (swift,
			-- latex). Swift's parser is built once via scripts/build-swift-parser.sh;
			-- highlighting/indent then work from master's bundled swift queries.
			ensure_installed = {
				-- web / TypeScript
				"typescript",
				"tsx",
				"javascript",
				"jsdoc",
				"html",
				"css",
				"json",
				"jsonc",
				-- Python
				"python",
				-- systems / misc
				"rust",
				"lua",
				"luadoc",
				"bash",
				"fish",
				"sql",
				"toml",
				"yaml",
				"markdown",
				"markdown_inline",
				"vim",
				"vimdoc",
				"csv",
				"gitignore",
				"gitcommit",
				"diff",
				"dockerfile",
				"regex",
			},
			sync_install = false,
			auto_install = false, -- installed parsers are managed explicitly (see :TSInstall)
			highlight = { enable = true }, -- also covers manually-installed parsers like swift
			indent = { enable = true },
			incremental_selection = {
				enable = true,
				keymaps = {
					init_selection = "e",
					node_incremental = "e",
					node_decremental = "E",
				},
			},
		})
	end,
}
