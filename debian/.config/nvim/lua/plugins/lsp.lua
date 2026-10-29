return {
    {
        "williamboman/mason.nvim",
        tag = "v1.11.0",
        build = ":MasonUpdate",
        priority = 1000,
        config = function()
            require("mason").setup({
                PATH = "prepend",  -- Ensures npm/go bins are in PATH
            })
        end,
    },
    {
        "williamboman/mason-lspconfig.nvim",
        tag = "v1.32.0",
        dependencies = { "williamboman/mason.nvim" },
        config = function()
            require("mason-lspconfig").setup({
                -- clangd: apt (clangd)
                ensure_installed = {
                    "lua_ls",         -- Lua
                    "pyright",        -- Python
                    "phpactor",       -- PHP (free alternative)
                    "ts_ls",          -- JavaScript/TypeScript
                    "bashls",         -- Bash / sh
                    "terraformls",    -- Terraform (covers HCL; closest for Packer)
                },
            })
        end,
    },
    {
        "neovim/nvim-lspconfig",
        tag = "v1.8.0",
        dependencies = { "williamboman/mason-lspconfig.nvim", "hrsh7th/cmp-nvim-lsp" },
        config = function()
            local lspconfig = require("lspconfig")
            local capabilities = require("cmp_nvim_lsp").default_capabilities()

            local on_attach = function(client, bufnr)
                local opts = { noremap = true, silent = true, buffer = bufnr }
                vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
                vim.keymap.set("n", "<leader>gd", vim.lsp.buf.definition, opts)
                vim.keymap.set({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, opts)

                -- Document highlight (optional)
                if client.supports_method("textDocument/documentHighlight") then
                    vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
                        buffer = bufnr,
                        callback = vim.lsp.buf.document_highlight,
                    })
                    vim.api.nvim_create_autocmd("CursorMoved", {
                        buffer = bufnr,
                        callback = vim.lsp.buf.clear_references,
                    })
                end
            end

            -- Lua
            lspconfig.lua_ls.setup({
                capabilities = capabilities,
                on_attach = on_attach,
                settings = {
                    Lua = {
                        diagnostics = { globals = { "vim" } },
                        runtime = { version = "LuaJIT" },
                        workspace = { checkThirdParty = false },
                        telemetry = { enable = false },
                    },
                },
            })

            -- Python (pyright)
            lspconfig.pyright.setup({
                capabilities = capabilities,
                on_attach = on_attach,
                settings = {
                    python = {
                        analysis = {
                            autoSearchPaths = true,
                            useLibraryCodeForTypes = true,
                            diagnosticMode = "workspace",
                        },
                    },
                },
            })

            -- PHP (phpactor)
            lspconfig.phpactor.setup({
                capabilities = capabilities,
                on_attach = on_attach,
            })

            -- JavaScript / TS
            lspconfig.ts_ls.setup({
                capabilities = capabilities,
                on_attach = on_attach,
            })

            -- C / C++
            lspconfig.clangd.setup({
                capabilities = capabilities,
                on_attach = on_attach,
                cmd = { "clangd", "--background-index", "--clang-tidy" },
            })

            -- Bash
            lspconfig.bashls.setup({
                capabilities = capabilities,
                on_attach = on_attach,
            })

            -- Terraform (and HCL / Packer approximation)
            lspconfig.terraformls.setup({
                capabilities = capabilities,
                on_attach = on_attach,
            })
        end,
    },
}
