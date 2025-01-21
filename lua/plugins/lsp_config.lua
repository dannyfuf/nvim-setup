return {
	-- Main LSP Configuration
	"neovim/nvim-lspconfig",
	dependencies = {
		{ "j-hui/fidget.nvim", opts = {} },
		"hrsh7th/cmp-nvim-lsp",
	},
	config = function()
		local lspconfig = require("lspconfig")
		local cmp_nvim_lsp = require("cmp_nvim_lsp")
		local keymap = vim.keymap
		local opts = { noremap = true, silent = true }
		local on_attach = function(client, bufnr)
			opts.buffer = bufnr

			opts.desc = "[G]oto [D]efinition"
			keymap.set("n", "gd", require("telescope.builtin").lsp_definitions, opts) --  To jump back, press <C-t>.

			opts.desc = "[G]oto [R]eferences"
			keymap.set("n", "gr", require("telescope.builtin").lsp_references, opts)

			opts.desc = "[G]oto [I]mplementation"
			keymap.set("n", "gI", require("telescope.builtin").lsp_implementations, opts)

			opts.desc = "Type [D]efinition"
			keymap.set("n", "<leader>D", require("telescope.builtin").lsp_type_definitions, opts)

			opts.desc = "[D]ocument [S]ymbols"
			keymap.set("n", "<leader>ds", require("telescope.builtin").lsp_document_symbols, opts)

			opts.desc = "[W]orkspace [S]ymbols"
			keymap.set("n", "<leader>ws", require("telescope.builtin").lsp_dynamic_workspace_symbols, opts)

			opts.desc = "[R]e[n]ame"
			keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts) -- Rename the variable under your cursor

			opts.desc = "[C]ode [A]ction"
			keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts) -- Execute a code action, usually your cursor needs to be on top of an error or a suggestion from your LSP for this to activate.

			opts.desc = "[G]oto [D]eclaration"
			keymap.set("n", "gD", vim.lsp.buf.declaration, opts)
		end

		local capabilities = cmp_nvim_lsp.default_capabilities()

		local signs = { Error = " ", Warn = " ", Hint = "󰠠 ", Info = " " }
		for type, icon in pairs(signs) do
			local hl = "DiagnosticSign" .. type
			vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
		end

		-- lspconfig.ruby_lsp.setup({
		--   capabilities = capabilities,
		--   on_attach = on_attach,
		-- })

		lspconfig.rubocop.setup({
			capabilities = capabilities,
			on_attach = on_attach,
		})

		lspconfig.sorbet.setup({
			root_dir = lspconfig.util.root_pattern(".git"),
			capabilities = capabilities,
			on_attach = on_attach,
		})
		lspconfig.ts_ls.setup({
			capabilities = capabilities,
			on_attach = on_attach,
		})
		lspconfig.eslint.setup({
			capabilities = capabilities,
			on_attach = on_attach,
		})
	end,
}
