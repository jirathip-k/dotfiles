return {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
        "nvim-treesitter/nvim-treesitter-textobjects",
    },
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
                "fish",
            },
            sync_install = false,
            highlight = { enable = true },
            indent = { enable = true },
            incremental_selection = {
                enable = true,
                keymaps = {
                    init_selection = "e",
                    node_incremental = "e",
                },
            },
        })

        local ts_utils = require("nvim-treesitter.ts_utils")



        local function tabout()
            local bufnr = vim.api.nvim_get_current_buf()
            local cursor = vim.api.nvim_win_get_cursor(0)
            local cursor_row, cursor_col = cursor[1] - 1, cursor[2] + 1
            local node = ts_utils.get_node_at_cursor()
            local exit_chars = "[,%)%}%]]"
            local default_tab = vim.api.nvim_replace_termcodes("<Tab>", true, false, true)
            local lines_count = vim.api.nvim_buf_line_count(0)

            while node do
                local node_type = node:type()

                if node_type == "string" or node_type == "string_fragment" then
                    local _, _, end_row, end_col = node:range()

                    if end_row < lines_count then
                        vim.api.nvim_win_set_cursor(0, { end_row + 1, end_col })
                        return
                    end
                end
                node = node:parent()
            end

            if cursor_row + 1 <= lines_count then
                local line = vim.api.nvim_buf_get_lines(bufnr, cursor_row, cursor_row + 1, false)[1]
                if line and cursor_col <= #line then
                    if line:sub(cursor_col, cursor_col):match(exit_chars) then
                        vim.api.nvim_win_set_cursor(0, { cursor_row + 1, cursor_col + 1 })
                    else
                        vim.api.nvim_feedkeys(default_tab, "n", true)
                    end
                elseif cursor_col > #line and cursor_row + 1 < lines_count then
                    local next_indent = vim.fn.indent(cursor_row + 2)
                    vim.api.nvim_win_set_cursor(0, { cursor_row + 2, next_indent })
                end
            end
        end

        vim.keymap.set("i", "<Tab>", tabout, { desc = "Tabout", silent = true, noremap = true })
    end
}
