return {
    "nvim-treesitter/nvim-treesitter",
    branch = "master",
    lazy = false,
    build = ":TSUpdate",
    config = function()
        local config = require("nvim-treesitter.configs")

        config.setup({
        ensure_installed = { 
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
            },
        highlight = { enable = true },
        indent = { enable = true },
        })
    end
}
