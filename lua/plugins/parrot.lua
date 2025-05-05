return {
	{
		"frankroeder/parrot.nvim",
		dependencies = { "ibhagwan/fzf-lua", "nvim-lua/plenary.nvim" },
		config = function()
			require("parrot").setup({
				providers = {
					anthropic = {
						api_key = os.getenv("ANTHROPIC_API_KEY"),
					},
					gemini = {
						api_key = os.getenv("GEMINI_API_KEY"),
					},
					openai = {
						api_key = os.getenv("OPENAI_API_KEY"),
					},
				},
			})

			vim.keymap.set("n", "pa", "<cmd>PrtAsk<cr>")
			vim.keymap.set("n", "pcn", "<cmd>PrtChatNew popup<cr>")
			vim.keymap.set("n", "pct", "<cmd>PrtChatToggle popup<cr>")
			vim.keymap.set("n", "pcr", "<cmd>PrtChatRespond<cr>")
			vim.keymap.set("n", "pcd", "<cmd>PrtChatDelete<cr>")
			vim.keymap.set("n", "ps", "<cmd>PrtStop<cr>")
			vim.keymap.set("n", "pt", "<cmd>PrtThinking<cr>")
		end,
	},
}
