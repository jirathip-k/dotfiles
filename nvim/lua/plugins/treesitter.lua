return {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
        local configs = require("nvim-treesitter.configs")

        configs.setup({
            ensure_installed = {
                "python",
                "rust",
                "lua",
                "sql",
                "toml",
                "yaml",
                "markdown",
                "latex",
                "json",
                "vim",
                "csv",
                "vimdoc",
                "typescript",
                "javascript",
                "html",
                "css",
                "tsx",
                "bash",
                "fish"
            },
            sync_install = false,
            highlight = { enable = true },
            indent = { enable = true },
            incremental_selection = {
                enable = true,
                keymaps = {
                    init_selection = "<leader> ",
                    node_incremental = "<leader> ",
                },
            },
            textobjects = {
                move = {
                    enable = true,
                    set_jumps = true, -- whether to set jumps in the jumplist
                    goto_next_start = {
                        ["]m"] = "@function.outer",
                        ["]]"] = "@class.outer",
                    },
                    goto_previous_start = {
                        ["[m"] = "@function.outer",
                        ["[["] = "@class.outer",
                    },
                },
            },
        })
    end,
}
