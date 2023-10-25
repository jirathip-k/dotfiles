return {
    "ThePrimeagen/harpoon",
    config = function()
        local mark = require("harpoon.mark")

        local ui = require("harpoon.ui")

        local opts = { noremap = true, silent = true }

        opts.desc = "Mark File"
        vim.keymap.set("n", "<leader>a", mark.add_file, opts)

        opts.desc = "Toggle Harpoon Menu"
        vim.keymap.set("n", "<C-e>", ui.toggle_quick_menu, opts)

        opts.desc = "File 1"
        vim.keymap.set("n", "<C-q>", function() ui.nav_file(1) end, opts)


        opts.desc = "File 2"
        vim.keymap.set("n", "<C-w>", function() ui.nav_file(2) end, opts)
    end
}
