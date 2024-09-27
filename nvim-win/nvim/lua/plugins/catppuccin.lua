return {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    dependencies = {
        "mvllow/modes.nvim",
    },
    config = function()
        local catppuccin = require("catppuccin")
        local frappe = require("catppuccin.palettes").get_palette("frappe")

        catppuccin.setup({
            flavour = "frappe", -- latte, frappe, macchiato, mocha
            transparent_background = true,
            integrations = {
                nvimtree = true,
                treesitter = true,
                telescope = true,
                which_key = true,
                cmp = true,
                mason = true,
                treesitter_context = false,
            },
            custom_highlights = function(colors)
                return {
                    LineNr = { fg = colors.overlay2 },
                    CursorLineNr = { fg = colors.mauve },
                    CursorLine = { bg = colors.none },
                    TreesitterContextLineNumber = { fg = colors.mantle, bg = colors.overlay2 },
                }
            end,
        })

        vim.cmd.colorscheme("catppuccin")

        local modes = require("modes")

        modes.setup({
            colors = {
                copy = frappe.yellow,
                insert = frappe.overlay1,
                visual = frappe.mauve,
                delete = frappe.red,
            },
            line_opacity = 0.60,
            set_cursor = false,
            set_cursorline = true,
            set_number = true,
        })
    end,
}
