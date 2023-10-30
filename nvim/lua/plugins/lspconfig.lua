return {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
        "hrsh7th/cmp-nvim-lsp",
    },
    config = function()
        local lspconfig = require("lspconfig")
        local cmp_nvim_lsp = require("cmp_nvim_lsp")
        local opts = { noremap = true, silent = true }
        local on_attach = function(client, bufnr)
            opts.buffer = bufnr

            opts.desc = "Show LSP Reference"
            vim.keymap.set("n", "<leader>fr", "<cmd>Telescope lsp_references<CR>", opts)

            opts.desc = "Show Documentation"
            vim.keymap.set("n", "<leader>d", vim.lsp.buf.hover, opts)

            opts.desc = "Restart LSP"
            vim.keymap.set("n", "<leader>L", ":LspRestart<CR>", opts)
        end

        local capabilities = cmp_nvim_lsp.default_capabilities()

        lspconfig["lua_ls"].setup({
            capabilities = capabilities,
            on_attach = on_attach,
            settings = {
                Lua = {
                    diagnostics = {
                        globals = { "vim" },
                    },
                    workspace = {
                        library = {
                            [vim.fn.expand("$VIMRUNTIME/lua")] = true,
                            [vim.fn.stdpath("config") .. "/lua"] = true,
                        },
                    },
                },
            },
        })
        lspconfig["rust_analyzer"].setup({
            capabilities = capabilities,
            on_attach = on_attach,
        })

        lspconfig["pyright"].setup({
            capabilities = capabilities,
            on_attach = on_attach,
            settings = {
                pyright = { autoImportCompletion = true, venvPath = "~/.cache/pypoetry/virtualenvs" },
                python = {
                    analysis = {
                        autoSearchPaths = true,
                    },
                },
            },
        })
        lspconfig["tsserver"].setup({
            capabilities = capabilities,
            on_attach = on_attach,
        })

        lspconfig["cssls"].setup({
            capabilities = capabilities,
            on_attach = on_attach,
        })
        lspconfig["tailwindcss"].setup({
            capabilities = capabilities,
            on_attach = on_attach,
        })

        lspconfig["html"].setup({
            capabilities = capabilities,
            on_attach = on_attach,
        })

        lspconfig["emmet_ls"].setup({
            capabilities = capabilities,
            on_attach = on_attach,
            filetypes = {
                "css",
                "eruby",
                "html",
                "javascript",
                "javascriptreact",
                "less",
                "sass",
                "scss",
                "svelte",
                "pug",
                "typescriptreact",
                "vue",
            },
        })
    end,
}
