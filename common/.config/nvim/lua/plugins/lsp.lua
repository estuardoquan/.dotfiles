-- vim.lsp.config / vim.lsp.enable exist from Neovim 0.11.
-- mason v2, mason-lspconfig v2 and nvim-lspconfig v2 require Neovim 0.11.
local has_011 = vim.fn.has("nvim-0.11") == 1

-- musl (Alpine): Mason has no musl build for lua_ls and clangd.
-- Those come from the system instead: apk add lua-language-server clang-extra-tools
local is_musl = vim.fn.glob("/lib/ld-musl-*.so.1") ~= ""

local function mason_servers()
    local servers = { "terraformls" }

    if not is_musl then
        vim.list_extend(servers, { "lua_ls", "clangd" })
    end

    if vim.fn.executable("npm") == 1 then
        vim.list_extend(servers, { "pyright", "ts_ls", "bashls" })
    end

    if vim.fn.executable("php") == 1 then
        table.insert(servers, "phpactor")
    end

    return servers
end

return {
    {
        "williamboman/mason.nvim",
        tag = not has_011 and "v1.11.0" or nil,
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
        tag = not has_011 and "v1.32.0" or nil,
        dependencies = { "williamboman/mason.nvim" },
        config = function()
            require("mason-lspconfig").setup({
                ensure_installed = mason_servers(),
                automatic_enable = false,
            })
        end,
    },
    {
        "neovim/nvim-lspconfig",
        tag = not has_011 and "v1.8.0" or nil,
        dependencies = { "williamboman/mason-lspconfig.nvim", "hrsh7th/cmp-nvim-lsp" },
        config = function()
            local capabilities = require("cmp_nvim_lsp").default_capabilities()

            local on_attach = function(client, bufnr)
                local opts = { noremap = true, silent = true, buffer = bufnr }
                vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
                vim.keymap.set("n", "<leader>gd", vim.lsp.buf.definition, opts)
                vim.keymap.set({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, opts)

                local method = "textDocument/documentHighlight"
                local supported
                if has_011 then
                    supported = client:supports_method(method)
                else
                    supported = client.supports_method(method)
                end

                -- Document highlight (optional)
                if supported then
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

            local servers = {
                -- Lua
                lua_ls = {
                    settings = {
                        Lua = {
                            diagnostics = { globals = { "vim" } },
                            runtime = { version = "LuaJIT" },
                            workspace = { checkThirdParty = false },
                            telemetry = { enable = false },
                        },
                    },
                },

                -- Python (pyright)
                pyright = {
                    settings = {
                        python = {
                            analysis = {
                                autoSearchPaths = true,
                                useLibraryCodeForTypes = true,
                                diagnosticMode = "workspace",
                            },
                        },
                    },
                },

                -- PHP (phpactor)
                phpactor = {},

                -- JavaScript / TS
                ts_ls = {},

                -- C / C++
                clangd = {
                    cmd = { "clangd", "--background-index", "--clang-tidy" },
                },

                -- Bash
                bashls = {},

                -- Terraform (and HCL / Packer approximation)
                terraformls = {},
            }

            for name, opts in pairs(servers) do
                opts = vim.tbl_extend("force", {
                    capabilities = capabilities,
                    on_attach = on_attach,
                }, opts)

                if has_011 then
                    vim.lsp.config(name, opts)
                    vim.lsp.enable(name)
                else
                    require("lspconfig")[name].setup(opts)
                end
            end
        end,
    },
}
