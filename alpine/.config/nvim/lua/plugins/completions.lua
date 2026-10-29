return {
	{
        "L3MON4D3/LuaSnip",
        dependencies = {
            "saadparwaiz1/cmp_luasnip",
            "rafamadriz/friendly-snippets",
            "hrsh7th/cmp-nvim-lsp"
        }
    },
	{
		"hrsh7th/nvim-cmp",
		config = function()
			require("luasnip.loaders.from_vscode").lazy_load()
            local cmp = require("cmp")

			cmp.setup({
				snippet = {
					expand = function(args)
                        require("luasnip").lsp_expand(args.body)
						-- vim.fn["vsnip#anonymous"](args.body) 
                    end,
				},
				window = {
                comps = cmp.config.window.bordered(),
                docs = cmp.config.window.bordered()
                },
				mapping = cmp.mapping.preset.insert({
					["<C-b>"] = cmp.mapping.scroll_docs(-4),
					["<C-f>"] = cmp.mapping.scroll_docs(4),
					["<C-Space>"] = cmp.mapping.complete(),
					["<C-e>"] = cmp.mapping.abort(),
					["<CR>"] = cmp.mapping.confirm({ select = true }),
				}),
				sources = cmp.config.sources({
				    { name = "nvim_lsp" },
					{ name = "luasnip" }, -- For luasnip users.
					-- { name = "vsnip" }, -- For vsnip users.
					-- { name = 'ultisnips' }, -- For ultisnips users.
					-- { name = 'snippy' }, -- For snippy users.
				}, {
					{ name = "buffer" },
				}),
			})
		end,
	},
}
