return {
  {
    "Fildo7525/pretty_hover",
    event = "LspAttach",
    opts = {},
    config = function()
      local hover = require("pretty_hover")

      vim.keymap.set("n", "<leader>h", function()
        hover.hover()
      end)

      -- ctrl-hh to close the hover window
      vim.keymap.set("n", "<leader>k", function()
        hover.close()
      end)
    end
  },
}
