-- Formatters via conform.nvim.
-- conform delegates each filetype to the listed formatter(s), running them
-- in order, the first available wins.

return {
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    dependencies = { "williamboman/mason.nvim" },
    opts = {
      ensure_installed = {
        "stylua",
        "clang-format",
        "ruff",
        "prettier",
        "shfmt",
      },
    },
  },
  {
    "stevearc/conform.nvim",
    event = { "BufWritePre" },
    cmd = { "ConformInfo" },
    config = function()
      require("conform").setup({
        formatters_by_ft = {
          c          = { "clang_format" },
          cpp        = { "clang_format" },
          python     = { "ruff_format" },
          lua        = { "stylua" },
          javascript = { "prettier" },
          typescript = { "prettier" },
          json       = { "prettier" },
          yaml       = { "prettier" },
          markdown   = { "prettier" },
          sh         = { "shfmt" },
          bash       = { "shfmt" },
        },
      })

      -- Manual format (existing keymap, preserved).
      vim.keymap.set("n", "<leader>gf", function()
        require("conform").format({ async = true, lsp_fallback = true })
      end, { silent = true, desc = "Format buffer" })
    end,
  },
}
