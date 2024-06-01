return {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
        "hrsh7th/cmp-nvim-lsp",
    },
    config = function()
        local lspconfig = require("lspconfig")
        local configs = require("lspconfig/configs")
        local cmp_nvim_lsp = require("cmp_nvim_lsp")
        local opts = { noremap = true, silent = true }
        local on_attach = function(_, bufnr)
            opts.buffer = bufnr

            opts.desc = "Show LSP Reference"
            vim.keymap.set("n", "gr", "<cmd>Telescope lsp_references<CR>", opts)

            opts.desc = "Go Declaration"
            vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts)

            opts.desc = "Go Definition"
            vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)

            opts.desc = "Show Documentation"
            vim.keymap.set("n", "<leader>d", vim.lsp.buf.hover, opts)

            opts.desc = "Code Action"
            vim.keymap.set("n", "<leader>c", vim.lsp.buf.code_action, opts)

            opts.desc = "Rename"
            vim.keymap.set("n", "<leader>r", vim.lsp.buf.rename, opts)

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
                    hint = { enable = true },
                },
            },
        })
        lspconfig["rust_analyzer"].setup({
            capabilities = capabilities,
            on_attach = on_attach,
        })

        lspconfig["gopls"].setup({
            capabilities = capabilities,
            on_attach = on_attach,
            filetypes = { "go", "templ" },
        })

        lspconfig["templ"].setup({
            capabilities = capabilities,
            on_attach = on_attach,
        })

        lspconfig["ruff_lsp"].setup({
            capabilities = capabilities,
            on_attach = on_attach,
        })

        lspconfig["pylsp"].setup({
            capabilities = capabilities,
            on_attach = on_attach,
            pylsp = {
                plugins = {
                    ruff = {
                        enable = true,
                    },
                    pycodestyle = {
                        enable = false,
                    },
                    pyflakes = {
                        enable = false,
                    },
                    mccabe = {
                        enable = false,
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
            filetypes = { "html", "templ" },
        })


        lspconfig["htmx"].setup({
            on_attach = on_attach,
            capabilities = capabilities,
            filetypes = { "html", "templ" },
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
