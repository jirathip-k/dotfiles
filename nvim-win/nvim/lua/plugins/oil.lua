return {
    "stevearc/oil.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
        local oil = require("oil")

        oil.setup({
            view_options = {
                show_hidden = true,
                is_always_hidden = function(name, bufnr)
                    return name == ".."
                end
            },
        })
    end,
}
