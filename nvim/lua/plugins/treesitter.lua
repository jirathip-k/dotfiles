return {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
        "nvim-treesitter/nvim-treesitter-textobjects",
        "nvim-treesitter/nvim-treesitter-context",
        "windwp/nvim-ts-autotag",
    },
    config = function()
        local configs = require("nvim-treesitter.configs")

        local tscontext = require("treesitter-context")
        tscontext.setup({
            multiline_threshold = 50,
            max_lines = -1,
        })

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
                "fish",
            },
            sync_install = false,
            highlight = { enable = true },
            indent = { enable = true },
            autotag = { enable = true },
            incremental_selection = {
                enable = true,
                keymaps = {
                    init_selection = "e",
                    node_incremental = "e",
                },
            },
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
            },
        })
    end,
}
