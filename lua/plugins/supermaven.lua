return {
	{
		"supermaven-inc/supermaven-nvim",
		config = function()
			require("supermaven-nvim").setup({
				keymaps = {
					accept_suggestion = "<Tab>",
					clear_suggestion = "<S-Tab>",
					accept_word = "<C-l>", -- Changed from <S-l> to <C-l> (Ctrl+L)
				},
			})
		end,
	},
}
