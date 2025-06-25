return {
	{
		"mfussenegger/nvim-lint",
		event = { "BufReadPre", "BufNewFile" },
		config = function()
      -- lint python with flake8
      require("lint").linters.flake8 = {
        exe = "flake8",
        args = { "--ignore=E501,W503" },
      }
    end,
	},
}
