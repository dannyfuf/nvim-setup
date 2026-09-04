return {
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      { "antosha417/nvim-lsp-file-operations", config = true },
    },
    config = function()
      local keymap = vim.keymap
      local capabilities = require("cmp_nvim_lsp").default_capabilities()

      local function ruby_root(bufnr)
        local path = vim.api.nvim_buf_get_name(bufnr)
        local sorbet_config = vim.fs.find("sorbet/config", { path = path, upward = true })[1]

        if sorbet_config then
          return vim.fs.dirname(vim.fs.dirname(sorbet_config))
        end

        local gemfile = vim.fs.find({ "Gemfile", ".git" }, { path = path, upward = true })[1]
        if gemfile then
          return vim.fs.dirname(gemfile)
        end
      end

      local function is_sorbet_typed(bufnr)
        local line_count = vim.api.nvim_buf_line_count(bufnr)
        local lines = vim.api.nvim_buf_get_lines(bufnr, 0, math.min(line_count, 5), false)

        for _, line in ipairs(lines) do
          if line:match("^#%s*typed:%s*[%w_%-]+") then
            return true
          end
        end

        return false
      end

      local function workspace_symbols()
        local query = vim.fn.input("Workspace symbols: ")
        if query == nil or query == "" then
          return
        end

        vim.lsp.buf.workspace_symbol(query)
      end

      local function regex_escape(text)
        return (text:gsub("([%^%$%(%)%%%.%[%]%*%+%-%?])", "%%%1"))
      end

      local function snake_case(text)
        local value = text:gsub("::", "/")
        value = value:gsub("([A-Z]+)([A-Z][a-z])", "%1_%2")
        value = value:gsub("([a-z%d])([A-Z])", "%1_%2")
        return value:lower()
      end

      local function ruby_constant_under_cursor()
        local cword = vim.fn.expand("<cword>")
        local cword_symbol = cword ~= "" and cword or nil
        local cWORD = vim.fn.expand("<cWORD>")
        local cWORD_symbol = cWORD ~= "" and cWORD:match("[A-Z][A-Za-z0-9_:]*") or nil

        if cWORD_symbol and cWORD_symbol:match("^[A-Z]") then
          return cWORD_symbol
        end

        if cword_symbol and cword_symbol:match("^[A-Z]") then
          return cword_symbol
        end
      end

      local function jump_to_first_location(location, offset_encoding)
        if location.uri then
          vim.lsp.util.jump_to_location(location, offset_encoding)
          return true
        end

        if location.targetUri then
          vim.lsp.util.jump_to_location({
            uri = location.targetUri,
            range = location.targetSelectionRange or location.targetRange,
          }, offset_encoding)
          return true
        end

        return false
      end

      local function ruby_file_definition()
        local constant = ruby_constant_under_cursor()
        if not constant then
          return false
        end

        local root = ruby_root(0)
        if not root then
          return false
        end

        local relative_path = snake_case(constant) .. ".rb"
        local direct_candidates = {
          root .. "/app/models/" .. relative_path,
          root .. "/app/services/" .. relative_path,
          root .. "/app/lib/" .. relative_path,
          root .. "/app/controllers/" .. relative_path,
          root .. "/app/jobs/" .. relative_path,
          root .. "/app/forms/" .. relative_path,
          root .. "/app/helpers/" .. relative_path,
          root .. "/app/mailers/" .. relative_path,
          root .. "/app/policies/" .. relative_path,
          root .. "/app/serializers/" .. relative_path,
          root .. "/app/uploaders/" .. relative_path,
          root .. "/lib/" .. relative_path,
        }

        for _, file in ipairs(direct_candidates) do
          if vim.uv.fs_stat(file) then
            vim.cmd.edit(vim.fn.fnameescape(file))
            return true
          end
        end

        local result = vim.system({
          "rg",
          "--files",
          "-g",
          relative_path,
          "-g",
          "*/" .. relative_path,
          root .. "/packs",
          root .. "/gems",
          root,
        }, { text = true }):wait()

        if result.code ~= 0 or not result.stdout or result.stdout == "" then
          return false
        end

        local matches = vim.split(result.stdout, "\n", { trimempty = true })
        table.sort(matches, function(a, b)
          local a_score = a:match("/app/") and 0 or (a:match("/lib/") and 1 or 2)
          local b_score = b:match("/app/") and 0 or (b:match("/lib/") and 1 or 2)
          if a_score == b_score then
            return a < b
          end
          return a_score < b_score
        end)

        local file = matches[1]
        if not file then
          return false
        end

        vim.cmd.edit(vim.fn.fnameescape(file))
        return true
      end

      local function ruby_grep_definition()
        local symbol = ruby_constant_under_cursor()
        if symbol == nil or symbol == "" then
          return false
        end

        local root = ruby_root(0)
        if not root then
          return false
        end

        local escaped_symbol = regex_escape(symbol)
        local pattern = string.format(
          [[^\s*(class|module)\s+((::)?[A-Z][A-Za-z0-9_]*::)*%s\b|^\s*%s\s*=]],
          escaped_symbol,
          escaped_symbol
        )

        local result = vim.system({
          "rg",
          "--line-number",
          "--column",
          "--glob",
          "*.rb",
          pattern,
          root,
        }, { text = true }):wait()

        if result.code ~= 0 or not result.stdout or result.stdout == "" then
          return false
        end

        local first_match = vim.split(result.stdout, "\n", { trimempty = true })[1]
        if not first_match then
          return false
        end

        local file, line, col = first_match:match("^(.-):(%d+):(%d+):")
        if not file then
          return false
        end

        vim.cmd.edit(vim.fn.fnameescape(file))
        vim.api.nvim_win_set_cursor(0, { tonumber(line), math.max(tonumber(col) - 1, 0) })
        return true
      end

      local function goto_definition()
        if vim.bo.filetype == "ruby" and ruby_file_definition() then
          return
        end

        local clients = vim.lsp.get_clients({ bufnr = 0, method = "textDocument/definition" })
        if #clients == 0 then
          if vim.bo.filetype == "ruby" and ruby_grep_definition() then
            return
          end

          vim.notify("No definition provider available", vim.log.levels.WARN)
          return
        end

        local offset_encoding = clients[1].offset_encoding or "utf-16"
        local responses = vim.lsp.buf_request_sync(
          0,
          "textDocument/definition",
          vim.lsp.util.make_position_params(0, offset_encoding),
          400
        ) or {}

        for client_id, response in pairs(responses) do
          if response and response.result and not vim.tbl_isempty(response.result) then
            local result = response.result
            local location = vim.islist(result) and result[1] or result
            local client = vim.lsp.get_client_by_id(client_id)

            if location and jump_to_first_location(location, client and client.offset_encoding or offset_encoding) then
              return
            end
          end
        end

        if vim.bo.filetype == "ruby" and ruby_grep_definition() then
          return
        end

        vim.notify("No locations found", vim.log.levels.INFO)
      end

      local function configure_diagnostics()
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
      end

      local function set_global_keymaps()
        local opts = { noremap = true, silent = true }

        keymap.set("n", "<leader>e", vim.diagnostic.open_float, opts)
        keymap.set("n", "[d", vim.diagnostic.goto_prev, opts)
        keymap.set("n", "]d", vim.diagnostic.goto_next, opts)
        keymap.set("n", "<leader>q", vim.diagnostic.setloclist, opts)
      end

      local function set_lsp_keymaps()
        local group = vim.api.nvim_create_augroup("UserLspAttach", { clear = true })

        vim.api.nvim_create_autocmd("LspAttach", {
          group = group,
          callback = function(ev)
            local bufopts = { noremap = true, silent = true, buffer = ev.buf }

            bufopts.desc = "[G]oto [D]efinition"
            keymap.set("n", "gd", goto_definition, bufopts)

            bufopts.desc = "[G]oto [R]eferences"
            keymap.set("n", "gr", vim.lsp.buf.references, bufopts)

            bufopts.desc = "[G]oto [I]mplementation"
            keymap.set("n", "gI", vim.lsp.buf.implementation, bufopts)

            bufopts.desc = "Type [D]efinition"
            keymap.set("n", "<leader>D", vim.lsp.buf.type_definition, bufopts)

            bufopts.desc = "[D]ocument [S]ymbols"
            keymap.set("n", "<leader>ds", vim.lsp.buf.document_symbol, bufopts)

            bufopts.desc = "[W]orkspace [S]ymbols"
            keymap.set("n", "<leader>ws", workspace_symbols, bufopts)

            bufopts.desc = "[R]e[n]ame"
            keymap.set("n", "<leader>rn", vim.lsp.buf.rename, bufopts)

            bufopts.desc = "[C]ode [A]ction"
            keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, bufopts)

            bufopts.desc = "[G]oto [D]eclaration"
            keymap.set("n", "gD", vim.lsp.buf.declaration, bufopts)

            bufopts.desc = "[R]estart [S]erver"
            keymap.set("n", "<leader>rs", "<cmd>LspRestart<CR>", bufopts)
          end,
        })
      end

      local function configure_servers()
        vim.lsp.config("sorbet", {
          capabilities = capabilities,
          root_dir = function(bufnr, on_dir)
            if is_sorbet_typed(bufnr) then
              on_dir(ruby_root(bufnr))
            end
          end,
          settings = {
            sorbet = {
              completion = true,
              hover = true,
            },
          },
        })

        vim.lsp.config("ruby_lsp", {
          capabilities = capabilities,
          root_dir = function(bufnr, on_dir)
            if not is_sorbet_typed(bufnr) then
              on_dir(ruby_root(bufnr))
            end
          end,
        })

        vim.lsp.config("rubocop", {
          capabilities = capabilities,
          cmd = { "bundle", "exec", "rubocop", "--lsp" },
          root_markers = { ".rubocop.yml", "Gemfile", ".git" },
          settings = {
            rubocop = {
              lint = true,
              format = true,
            },
          },
        })

        vim.lsp.config("denols", {
          capabilities = capabilities,
          cmd = { "deno", "lsp" },
          root_markers = { "deno.json", "deno.jsonc" },
          settings = {
            deno = {
              enable = true,
              unstable = true,
            },
          },
        })

        vim.lsp.config("biome", {
          capabilities = capabilities,
        })

        vim.lsp.config("ts_ls", {
          capabilities = capabilities,
        })

        vim.lsp.config("lua_ls", {
          capabilities = capabilities,
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

        vim.lsp.config("pyright", {
          capabilities = capabilities,
        })

        vim.lsp.enable({ "sorbet", "ruby_lsp", "rubocop", "denols", "biome", "ts_ls", "lua_ls", "pyright" })
      end

      local function configure_format_on_save()
        local group = vim.api.nvim_create_augroup("LspFormatOnSave", { clear = true })

        vim.api.nvim_create_autocmd("BufWritePre", {
          group = group,
          pattern = { "*.rb", "*.erb", "*.rake", "Gemfile", "Rakefile" },
          callback = function(ev)
            if vim.g.disable_autoformat or vim.b[ev.buf].disable_autoformat then
              return
            end

            for _, client in pairs(vim.lsp.get_clients({ bufnr = ev.buf })) do
              if client.name == "rubocop" and client.server_capabilities.documentFormattingProvider then
                vim.lsp.buf.format({
                  bufnr = ev.buf,
                  filter = function(format_client)
                    return format_client.name == "rubocop"
                  end,
                  timeout_ms = 3000,
                })
                return
              end
            end
          end,
        })
      end

      configure_diagnostics()
      set_global_keymaps()
      set_lsp_keymaps()
      configure_servers()
      configure_format_on_save()
    end,
  },
}
