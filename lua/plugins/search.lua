return {
  {
    "dmtrKovalenko/fff.nvim",
    build = function()
      require("fff.download").download_or_build_binary()
    end,
    lazy = false,
    opts = {
      debug = {
        enabled = true,
        show_scores = true,
      },
    },
    keys = {
      {
        "<leader>sf",
        function()
          require("fff").find_files()
        end,
        desc = "FFFind files",
      },
      {
        "<leader>sg",
        function()
          require("fff").live_grep()
        end,
        desc = "LiFFFe grep",
      },
      {
        "<leader>sz",
        function()
          require("fff").live_grep({
            grep = {
              modes = { "fuzzy", "plain" },
            },
          })
        end,
        desc = "Live fffuzy grep",
      },
      {
        "<leader>sc",
        function()
          require("fff").live_grep({ query = vim.fn.expand("<cword>") })
        end,
        desc = "Search current word",
      },
    },
  },
}
