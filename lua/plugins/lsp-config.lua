return {
	{
		"neovim/nvim-lspconfig",
		event = { "BufReadPre", "BufNewFile" },
		dependencies = {
			"hrsh7th/cmp-nvim-lsp",
			{ "antosha417/nvim-lsp-file-operations", config = true },
		},
		config = function()
			-- Import lspconfig
			local lspconfig = require("lspconfig")
			local cmp_nvim_lsp = require("cmp_nvim_lsp")
			local keymap = vim.keymap

			local opts = { noremap = true, silent = true }

			-- LSP keybindings that are available without an LSP attached
			keymap.set("n", "<leader>e", vim.diagnostic.open_float, opts)
			keymap.set("n", "[d", vim.diagnostic.goto_prev, opts)
			keymap.set("n", "]d", vim.diagnostic.goto_next, opts)
			keymap.set("n", "<leader>q", vim.diagnostic.setloclist, opts)

			local on_attach = function(client, bufnr)
				opts.buffer = bufnr

				-- Set keybinds
				keymap.set("n", "gR", "<cmd>Telescope lsp_references<CR>", opts) -- Show definition, references
				keymap.set("n", "gD", vim.lsp.buf.declaration, opts) -- Go to declaration
				keymap.set("n", "gd", "<cmd>Telescope lsp_definitions<CR>", opts) -- Show LSP definitions
				keymap.set("n", "gi", "<cmd>Telescope lsp_implementations<CR>", opts) -- Show LSP implementations
				keymap.set("n", "gt", "<cmd>Telescope lsp_type_definitions<CR>", opts) -- Show LSP type definitions
				keymap.set("n", "gr", "<cmd>Telescope lsp_references<CR>", opts) -- Show LSP references
				keymap.set({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, opts) -- See available code actions
				keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts) -- Smart rename
				keymap.set("n", "<leader>D", "<cmd>Telescope diagnostics bufnr=0<CR>", opts) -- Show diagnostics for file
				keymap.set("n", "<leader>d", vim.diagnostic.open_float, opts) -- Show diagnostics for line
				keymap.set("n", "K", vim.lsp.buf.hover, opts) -- Show documentation for what is under cursor
				keymap.set("n", "<leader>rs", ":LspRestart<CR>", opts) -- Restart LSP

				-- Format keybinding
				keymap.set("n", "<leader>f", function()
					vim.lsp.buf.format({ async = true })
				end, opts)
			end

			-- Used to enable autocompletion (assign to every lsp server config)
			local capabilities = cmp_nvim_lsp.default_capabilities()

			-- Configure diagnostic display
			vim.diagnostic.config({
				virtual_text = {
					prefix = "●",
					source = "if_many",
				},
				float = {
					source = "always",
					border = "rounded",
				},
				signs = true,
				underline = true,
				update_in_insert = false,
				severity_sort = true,
			})

			-- Change diagnostic symbols in the sign column (gutter)
			local signs = { Error = " ", Warn = " ", Hint = "󰠠 ", Info = " " }
			for type, icon in pairs(signs) do
				local hl = "DiagnosticSign" .. type
				vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
			end

			-- Configure Sorbet LSP for Ruby
			lspconfig["sorbet"].setup({
				capabilities = capabilities,
				on_attach = function(client, bufnr)
					-- Disable Sorbet formatting in favor of RuboCop
					client.server_capabilities.documentFormattingProvider = false
					client.server_capabilities.documentRangeFormattingProvider = false
					on_attach(client, bufnr)
				end,
				cmd = { "srb", "tc", "--lsp" },
				root_dir = lspconfig.util.root_pattern("sorbet/config", "Gemfile", ".git"),
				settings = {
					sorbet = {
						completion = true,
						hover = true,
					},
				},
				init_options = {
					highlightUntyped = true,
				},
			})

			-- Configure RuboCop LSP for Ruby
			lspconfig["rubocop"].setup({
				capabilities = capabilities,
				on_attach = on_attach,
				cmd = { "bundle", "exec", "rubocop", "--lsp" },
				root_dir = lspconfig.util.root_pattern(".rubocop.yml", "Gemfile", ".git"),
				settings = {
					rubocop = {
						lint = true,
						format = true,
					},
				},
			})

			-- Configure Deno LSP
			lspconfig["denols"].setup({
				capabilities = capabilities,
				on_attach = on_attach,
				cmd = { "deno", "lsp" },
				root_dir = lspconfig.util.root_pattern("deno.json", "deno.jsonc", "tsconfig.json"),
				settings = {
					deno = {
						enable = true,
						unstable = true,
					},
				},
			})

			-- Configure Lua LSP for Neovim development
			lspconfig["lua_ls"].setup({
				capabilities = capabilities,
				on_attach = on_attach,
				settings = {
					Lua = {
						diagnostics = {
							globals = { "vim" },
						},
						workspace = {
							library = {
								[vim.fn.expand("$VIMRUNTIME/lua")] = true,
								[vim.fn.stdpath("config") .. "/lua"] = true,
							},
						},
					},
				},
			})

			-- Format on save for Ruby files using LSP
			local format_on_save_group = vim.api.nvim_create_augroup("LspFormatOnSave", { clear = true })

			vim.api.nvim_create_autocmd("BufWritePre", {
				group = format_on_save_group,
				pattern = { "*.rb", "*.erb", "*.rake", "Gemfile", "Rakefile" },
				callback = function(ev)
					-- Check if autoformat is disabled
					if vim.g.disable_autoformat or vim.b[ev.buf].disable_autoformat then
						return
					end

					-- Get available LSP clients for this buffer
					local clients = vim.lsp.get_active_clients({ bufnr = ev.buf })
					local rubocop_client = nil

					-- Find RuboCop client
					for _, client in pairs(clients) do
						if client.name == "rubocop" then
							rubocop_client = client
							break
						end
					end

					-- Format with RuboCop if available
					if rubocop_client and rubocop_client.server_capabilities.documentFormattingProvider then
						vim.lsp.buf.format({
							bufnr = ev.buf,
							filter = function(client)
								return client.name == "rubocop"
							end,
							timeout_ms = 3000,
						})
					end
				end,
			})
		end,
	},
}
