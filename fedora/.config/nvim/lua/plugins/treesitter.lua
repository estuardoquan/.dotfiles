return {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    lazy = false,
    build = ":TSUpdate",
    config = function()
        require("nvim-treesitter").install({
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
        })

        vim.api.nvim_create_autocmd("FileType", {
            callback = function(args)
                if pcall(vim.treesitter.start, args.buf) then
                    vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
                end
            end,
        })
    end,
}
