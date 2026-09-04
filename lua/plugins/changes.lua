return {
	dir = "~/personal/changes.nvim",
	name = "changes.nvim",
	config = function()
		require("changes").setup()

		vim.keymap.set("n", "<leader>gc", function()
			require("changes").toggle()
		end, { desc = "Changes: toggle branch file tree" })
	end,
}
