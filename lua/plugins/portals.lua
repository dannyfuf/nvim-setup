return {
	{
		"cbochs/portal.nvim",
		-- Optional dependencies
		dependencies = {
			"cbochs/grapple.nvim",
			"ThePrimeagen/harpoon",
		},
		config = function()
			require("portal").setup()
			vim.keymap.set("n", "<leader>o", "<cmd>Portal jumplist backward<cr>")
			vim.keymap.set("n", "<leader>i", "<cmd>Portal jumplist forward<cr>")
		end,
	},
}
