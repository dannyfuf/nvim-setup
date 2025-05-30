return {
	{
		dir = vim.fn.expand("~/personal/foundation"),
		name = "foundation",
		dependencies = {
			"https://github.com/LuaDist/dkjson",
			"https://github.com/lunarmodules/luasocket",
		},
		config = function()
			require("foundation").setup()
		end,
	},
}
