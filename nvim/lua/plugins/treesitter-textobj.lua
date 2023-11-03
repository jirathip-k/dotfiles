return {
    "nvim-treesitter/nvim-treesitter-textobjects",
    lazy = true,
    config = function()
        local tree = require("nvim-treesitter.configs")

        tree.setup({
            textobjects = {
                move = {
                    enable = true,
                    set_jumps = true,
                    goto_next_start = {
                        ["]="] = { query = "@assignment.outer", desc = "Go to next assignment" },
                        ["]p"] = { query = "@parameter.inner", desc = "Go to next parameter" },
                        ["]f"] = { query = "@function.outer", desc = "Go to next function" },
                        ["]c"] = { query = "@class.outer", desc = "Go to next class" },
                    },
                    goto_previous_start = {
                        ["[="] = { query = "@assignment.outer", desc = "Go to prev assignment" },
                        ["[p"] = { query = "@parameter.inner", desc = "Go to prev parameter" },
                        ["[f"] = { query = "@function.outer", desc = "Go to prev function" },
                        ["[c"] = { query = "@class.outer", desc = "Go to prev class" },
                    },
                },
                swap = {
                    enable = true,
                    swap_next = {
                        ["snp"] = { query = "@parameter.inner", desc = "Swap next parameter" },
                        ["sn="] = { query = "@assignmnt.outer", desc = "Swap next assigment" },
                        ["snf"] = { quey = "@function.outer", desc = "Swap next function" },
                    },
                    swap_previous = {
                        ["spp"] = { query = "@parameter.inner", desc = "Swap prev parameter" },
                        ["sp="] = { query = "@parameter.outer", desc = "Swap prev assignment" },
                        ["spf"] = { quey = "@function.outer", desc = "Swap prev function" },
                    },
                },
            },
        })
    end,
}
