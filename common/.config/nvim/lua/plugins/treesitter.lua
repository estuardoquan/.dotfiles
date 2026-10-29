-- nvim-treesitter `master` supports Neovim 0.10/0.11 only.
-- nvim-treesitter `main` requires Neovim 0.12+ and the `tree-sitter` CLI.
local has_012 = vim.fn.has("nvim-0.12") == 1

local languages = {
    "arduino",
    "asm",
    "bash",
    "c",
    "cmake",
    "cpp",
    "css",
    "disassembly",
    "dockerfile",
    "html",
    "javascript",
    "json",
    "lua",
    "make",
    "markdown",
    "nginx",
    "passwd",
    "php",
    "sql",
    "vim",
    "vimdoc",
    "vue",
    "yaml",
    "zig",
}

return {
    "nvim-treesitter/nvim-treesitter",
    branch = has_012 and "main" or "master",
    lazy = false,
    build = ":TSUpdate",
    config = function()
        if not has_012 then
            require("nvim-treesitter.configs").setup({
                ensure_installed = languages,
                highlight = { enable = true },
                indent = { enable = true },
            })
            return
        end

        local ts = require("nvim-treesitter")
        ts.setup()

        if vim.fn.executable("tree-sitter") == 1 then
            ts.install(languages)
        end

        vim.api.nvim_create_autocmd("FileType", {
            group = vim.api.nvim_create_augroup("treesitter_start", { clear = true }),
            callback = function(args)
                if pcall(vim.treesitter.start, args.buf) then
                    vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
                end
            end,
        })
    end,
}
