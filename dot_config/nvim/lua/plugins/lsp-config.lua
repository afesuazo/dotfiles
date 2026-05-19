-- LSP setup: Mason installs the servers, mason-lspconfig bridges them to
-- nvim-lspconfig, nvim-lspconfig configures each one.
--
-- Server list:
--   clangd        C/C++
--   basedpyright  Python (modern fork of pyright, stricter defaults)
--   lua_ls        Lua (for editing this config)
--   bashls        Bash (for bootstrap/install.sh, packages/install.sh, shell modules)
--   taplo         TOML
--   yamlls        YAML
--   jsonls        JSON

local SERVERS = {
  "clangd",
  "basedpyright",
  "lua_ls",
  "bashls",
  "taplo",
  "yamlls",
  "jsonls",
}

return {
  {
    "williamboman/mason.nvim",
    config = true,
  },
  {
    "williamboman/mason-lspconfig.nvim",
    dependencies = { "williamboman/mason.nvim" },
    opts = {
      ensure_installed = SERVERS,
      automatic_installation = true,
    },
  },
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "williamboman/mason-lspconfig.nvim",
      "hrsh7th/cmp-nvim-lsp",
    },
    config = function()
      local lspconfig = require("lspconfig")
      local capabilities = require("cmp_nvim_lsp").default_capabilities()

      -- Keymaps applied once per attached buffer.
      local on_attach = function(_, bufnr)
        local map = function(mode, lhs, rhs)
          vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, silent = true })
        end
        map("n", "K",          vim.lsp.buf.hover)
        map("n", "<leader>cd", vim.lsp.buf.definition)
        map("n", "<leader>cr", vim.lsp.buf.references)
        map("n", "<leader>ca", vim.lsp.buf.code_action)
        map("n", "<leader>cn", vim.lsp.buf.rename)
        map("n", "[d",         vim.diagnostic.goto_prev)
        map("n", "]d",         vim.diagnostic.goto_next)
      end

      -- Per-server overrides.
      local server_overrides = {
        lua_ls = {
          settings = {
            Lua = {
              -- Recognize `vim` as a global in nvim config files.
              diagnostics = { globals = { "vim" } },
            },
          },
        },
      }

      for _, server in ipairs(SERVERS) do
        local opts = vim.tbl_deep_extend("force", {
          capabilities = capabilities,
          on_attach = on_attach,
        }, server_overrides[server] or {})
        lspconfig[server].setup(opts)
      end
    end,
  },
}
