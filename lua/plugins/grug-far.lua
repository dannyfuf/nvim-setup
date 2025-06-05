return {
	{
		"MagicDuck/grug-far.nvim",
		version = "1.6.3", -- Pin to version compatible with nvim 0.10
		config = function()
			local grug_far = require("grug-far")

			vim.keymap.set("n", "<leader>ff", function()
				grug_far.open()
			end, { desc = "Toggle Grug Far" })
		end,
	},
}
