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

        opts.desc = "[R]estart [S]erver"
        keymap.set("n", "<leader>rs", ":LspRestart<CR>", opts)
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
        signs = {
          text = {
            [vim.diagnostic.severity.ERROR] = " ",
            [vim.diagnostic.severity.WARN] = " ",
            [vim.diagnostic.severity.HINT] = "󰠠 ",
            [vim.diagnostic.severity.INFO] = " ",
          },
        },
        underline = true,
        update_in_insert = false,
        severity_sort = true,
      })

      -- Configure Sorbet LSP for Ruby
      lspconfig["sorbet"].setup({
        capabilities = capabilities,
        on_attach = on_attach,
        root_dir = lspconfig.util.root_pattern("sorbet/config", "Gemfile.lock", ".git"),
        settings = {
          sorbet = {
            completion = true,
            hover = true,
          },
        }
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

      lspconfig["pyright"].setup({
        capabilities = capabilities,
        on_attach = on_attach,
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
