return {
  {
    "akinsho/toggleterm.nvim",
    version = "*", -- Use the latest stable version
    config = function()
      require("toggleterm").setup{
        size = 20, -- Default size; can be overridden per terminal
        open_mapping = [[<c-\>]], -- Default keybinding to toggle terminal
        hide_numbers = true, -- Hide line numbers in the terminal
        shade_filetypes = {},
        shade_terminals = true,
        shading_factor = 2, -- Adjust the shading of terminal background
        start_in_insert = true,
        insert_mappings = true,
        persist_size = true,
        direction = 'float', -- Set default direction to float
        close_on_exit = true,
        shell = vim.o.shell, -- Use the default shell
        float_opts = {
          border = 'curved', -- Border style: 'single', 'double', 'rounded', 'solid', 'shadow', or 'curved'
          winblend = 10, -- Transparency
          highlights = {
            border = "Normal",
            background = "Normal",
          }
        }
      }
    end
  },
}