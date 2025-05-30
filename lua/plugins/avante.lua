return {
	{
		"yetone/avante.nvim",
		event = "VeryLazy",
		version = false, -- Never set this value to "*"! Never!
		keys = {
			{ "<leader>ad", "<cmd>AvanteClear<cr>", desc = "Clear Avante context" },
		},
		opts = {
			provider = "claude",
			claude = {
				model = "claude-3-7-sonnet-20240307",
				timeout = 60000,
				temperature = 0.1,
				max_tokens = 12000,
			},
			web_search_engine = {
				provider = "google",
			},
			rag_service = {
				enabled = true,
				host_mount = "~/fintoc",
				provider = "openai",
				endpoint = "https://api.openai.com/v1",
				llm_model = "",
				embed_model = "",
			},
		},
		build = "make",
		dependencies = {
			"nvim-treesitter/nvim-treesitter",
			"stevearc/dressing.nvim",
			"nvim-lua/plenary.nvim",
			"MunifTanjim/nui.nvim",
			"echasnovski/mini.pick",
			"nvim-telescope/telescope.nvim",
			"hrsh7th/nvim-cmp",
			"ibhagwan/fzf-lua",
			"nvim-tree/nvim-web-devicons",
			"zbirenbaum/copilot.lua",
			{
				"HakonHarnes/img-clip.nvim",
				event = "VeryLazy",
				opts = {
					default = {
						embed_image_as_base64 = false,
						prompt_for_file_name = false,
						drag_and_drop = {
							insert_mode = true,
						},
						use_absolute_path = true,
					},
				},
			},
			{
				"MeanderingProgrammer/render-markdown.nvim",
				opts = {
					file_types = { "markdown", "Avante" },
				},
				ft = { "markdown", "Avante" },
			},
		},
	},
}
