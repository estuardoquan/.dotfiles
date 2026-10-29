return {
    'nvim-lualine/lualine.nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    config = function()
        require("lualine").setup({
            options = {
--                component_separators = { left = '', right = ''},
--                section_separators = { left = '', right = ''},
                theme = 'seoul256'
--                theme = 'auto'
            }
        })
    end
}
