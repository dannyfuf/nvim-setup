return {
  "AxelGard/oneokai.nvim",
  config = function()
    local oneokai = require("oneokai")

    oneokai.setup({
      style = "black",
    })
    oneokai.load()
  end
}
