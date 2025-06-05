return {
	{
		"williamboman/mason.nvim",
		dependencies = {
			"williamboman/mason-lspconfig.nvim",
			"WhoIsSethDaniel/mason-tool-installer.nvim",
		},
		config = function()
			local mason = require("mason")
			local mason_lspconfig = require("mason-lspconfig")
			local mason_tool_installer = require("mason-tool-installer")

			mason.setup({
				ui = {
					icons = {
						package_installed = "✓",
						package_pending = "➜",
						package_uninstalled = "✗",
					},
				},
			})

			mason_lspconfig.setup({
				ensure_installed = {
					"lua_ls",
					"sorbet",
					-- "ruby_lsp",
					"ts_ls",
					"eslint",
					"gopls",
					"denols",
					"astro",
				},
				automatic_installation = true,
				automatic_enable = false,
			})

			mason_tool_installer.setup({
				ensure_installed = {
					"stylua",
					"eslint_d",
					"rubocop",
				},
			})
		end,
	},
}
