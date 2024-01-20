return {
	{
		"EdenEast/nightfox.nvim",
		lazy = false,
		priority = 1000,
		config = function()
			require("nightfox").setup({
		    -- custom values here	
      })
			vim.cmd.colorscheme("dawnfox")
		end,
	},
}
