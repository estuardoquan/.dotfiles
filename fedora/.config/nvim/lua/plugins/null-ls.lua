return {
    "nvimtools/none-ls.nvim",
    dependencies = {
        "nvimtools/none-ls-extras.nvim",
    },
    config = function()
        local null_ls = require("null-ls")
        local f = null_ls.builtins.formatting
        local d = null_ls.builtins.diagnostics

        null_ls.setup({
            sources = {
                require("none-ls.diagnostics.eslint_d"),
                f.stylua,
                f.prettier,
            },
        })

        vim.keymap.set("n", "<leader>gf", vim.lsp.buf.format, {})
    end,
}
