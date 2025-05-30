return {
	{
		"MagicDuck/grug-far.nvim",
		config = function()
			local grug_far = require("grug-far")

			vim.keymap.set("n", "<leader>ff", function()
				grug_far.open()
			end, { desc = "Toggle Grug Far" })
		end,
	},
}
