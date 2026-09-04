return {
  {
    "stevearc/conform.nvim",
    config = function()
      require("conform").setup({
        formatters_by_ft = {
          javascript = { "biome" },
          javascriptreact = { "biome" },
          python = { "black" },
          typescript = { "biome" },
          typescriptreact = { "biome" },
          json = { "biome" },
          jsonc = { "biome" },
        },
        format_on_save = {
          timeout_ms = 100000,
          lsp_format = "fallback",
        }
      })
    end
  },
}
