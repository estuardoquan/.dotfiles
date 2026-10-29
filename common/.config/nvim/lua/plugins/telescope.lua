return {
    {
        'nvim-telescope/telescope.nvim',
        -- 0.1.8 calls nvim-treesitter `master` modules that do not exist on `main` (Neovim 0.12).
        tag = vim.fn.has("nvim-0.11") == 1 and 'v0.2.2' or '0.1.8',
        dependencies = { 'nvim-lua/plenary.nvim' },
        config = function()
            local builtin = require("telescope.builtin")

            vim.keymap.set('n', '<C-p>', builtin.find_files, {})
            vim.keymap.set('n', '<leader>fg', builtin.live_grep, {})
        end
    },
    {
        "nvim-telescope/telescope-ui-select.nvim",
        config = function()
            require("telescope").setup(
            {
                ["ui-select"] = {
                        require("telescope.themes").get_dropdown{}
                }
            })
            require("telescope").load_extension("ui-select")
        end
    }
}
