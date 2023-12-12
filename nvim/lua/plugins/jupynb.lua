return {
    {
        "GCBallesteros/jupytext.nvim",
        lazy = false,
        config = true
    },
    {
        "GCBallesteros/NotebookNavigator.nvim",
        keys = {
            { "]h",        function() require("notebook-navigator").move_cell "d" end },
            { "[h",        function() require("notebook-navigator").move_cell "u" end },
            { "<leader>X", "<cmd>lua require('notebook-navigator').run_cell()<cr>" },
            { "<leader>x", "<cmd>lua require('notebook-navigator').run_and_move()<cr>" },
        },
        dependencies = {
            "echasnovski/mini.comment",
            "hkupty/iron.nvim",
            "anuvyklack/hydra.nvim",
        },
        event = "VeryLazy",
        config = function()
            local nn = require("notebook-navigator")
            local iron = require("iron.core")
            local view = require("iron.view")

            nn.setup({ activate_hydra_keys = "<leader>h" })
            iron.setup({
                config = {
                    repl_open_cmd = view.split.vertical.botright("40%")
                }
            })
        end,
    },
}
