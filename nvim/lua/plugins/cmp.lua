return {
	"hrsh7th/nvim-cmp",
	event = "InsertEnter",
	dependencies = {
		{ "L3MON4D3/LuaSnip" },
		{ "hrsh7th/cmp-buffer" },
		{ "hrsh7th/cmp-path" },
		{ "saadparwaiz1/cmp_luasnip" },
		{ "zbirenbaum/copilot-cmp" },
		{ "onsails/lspkind.nvim" },
	},
	config = function()
		local cmp = require("cmp")
		local luasnip = require("luasnip")
		local lspkind = require("lspkind")

		require("copilot_cmp").setup()

		cmp.setup({
			completion = {
				completeopt = "menu,menuone,preview,noselect",
			},
			snippet = {
				expand = function(args)
					luasnip.lsp_expand(args.body)
				end,
			},
			mapping = cmp.mapping.preset.insert({
				["k"] = cmp.mapping.select_prev_item(),
				["j"] = cmp.mapping.select_next_item(),
				["\\"] = cmp.mapping.abort(),
				["<CR>"] = cmp.mapping.confirm(),
			}),
			sources = {
				{ name = "copilot" },
				{ name = "nvim_lsp" },
				{ name = "buffer" },
				{ name = "path" },
			},
			formatting = {
				format = lspkind.cmp_format({
					mode = "symbol_text",
					max_width = 50,
					symbol_map = { Copilot = "" },
				}),
			},
		})
	end,
}
