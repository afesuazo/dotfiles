return {
	"nvimtools/none-ls.nvim",
	config = function()
		local null_ls = require("null-ls")
		null_ls.setup({
			sources = {
        -- General
				null_ls.builtins.formatting.prettier,
				-- Lua
        null_ls.builtins.formatting.stylua,
				-- CPP
				-- Python
        null_ls.builtins.formatting.ruff,
			},
		})

		vim.keymap.set("n", "<leader>gf", vim.lsp.buf.format, {})
	end,
}
