return {
    "stevearc/oil.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
        local oil = require("oil")
        -- Open parent dir
        vim.keymap.set("n", "-", "<CMD>Oil<CR>", { desc = "Open parent directory" })
        -- Previous Buffer
        vim.keymap.set("n", "=", ":b#<CR>", { desc = "Previous buffer", noremap = true, silent = true })

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
