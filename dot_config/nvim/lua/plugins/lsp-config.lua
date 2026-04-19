return {
	{
		"williamboman/mason.nvim",
		opts = {
			ensure_installed = {
				"clangd",
				"clang-format",
				"codelldb",
			},
		},
	},
	{
		"neovim/nvim-lspconfig",
		config = function()
			local base = require("cmp_nvim_lsp")
			local capabilities = base.default_capabilities()
			local on_attach = base.on_attach
			local lspconfig = require("lspconfig")

			lspconfig.lua_ls.setup({
				capabilities = capabilities,
			})

			require("lspconfig").clangd.setup({
				capabilities = capabilities; 
				on_attach = on_attach,
				settings = {
					clangd = {
						arguments = {
							"--query-driver=/opt/homebrew/opt/llvm@16/bin/clang++",
							"--system-headers",
							extraArgs = {
								"-I/opt/homebrew/opt/llvm@16/bin/../include/c++/v1",
							},
						},
					},
				},
			})

			vim.keymap.set("n", "K", vim.lsp.buf.hover, {})
			vim.keymap.set("n", "<leader>cd", vim.lsp.buf.definition, {})
			vim.keymap.set("n", "<leader>cr", vim.lsp.buf.references, {})
			vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, {})
		end,
	},
}
