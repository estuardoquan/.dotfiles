return {
    {
        "williamboman/mason.nvim",
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
        dependencies = { "williamboman/mason.nvim" },
        config = function()
            require("mason-lspconfig").setup({
                ensure_installed = {
                    "lua_ls",         -- Lua 
                    "pyright",        -- Python
                    "phpactor",       -- PHP (free alternative)
                    "ts_ls",          -- JavaScript/TypeScript
                    "clangd",         -- C / C++
                    "bashls",         -- Bash / sh
                    "terraformls",    -- Terraform (covers HCL; closest for Packer)
                },
                automatic_installation = true,
            })
        end,
    },
    {
        "neovim/nvim-lspconfig",
        dependencies = { "hrsh7th/cmp-nvim-lsp" },
        config = function()
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
            vim.lsp.config("lua_ls", {
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
            vim.lsp.config("pyright", {
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
            vim.lsp.config("phpactor", {
                capabilities = capabilities,
                on_attach = on_attach,
            })

            -- JavaScript / TS
            vim.lsp.config("ts_ls", {
                capabilities = capabilities,
                on_attach = on_attach,
            })

            -- C / C++
            vim.lsp.config("clangd", {
                capabilities = capabilities,
                on_attach = on_attach,
                cmd = { "clangd", "--background-index", "--clang-tidy" },
            })

            -- Bash
            vim.lsp.config("bashls", {
                capabilities = capabilities,
                on_attach = on_attach,
            })

            -- Terraform (and HCL / Packer approximation)
            vim.lsp.config("terraformls", {
                capabilities = capabilities,
                on_attach = on_attach,
            })

            -- Enable
            vim.lsp.enable({
                "lua_ls",
                "pyright",
                "phpactor",
                "ts_ls",
                "clangd",
                "bashls",
                "terraformls",
            })
        end,
    },
}
