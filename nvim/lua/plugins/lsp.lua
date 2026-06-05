return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        vtsls = {},
        vue_ls = {},
        pyright = {},
        gopls = {},
        rust_analyzer = {},
        tailwindcss = {},
        prismals = {},
        graphql = {},
        dockerls = {},
        yamlls = {},
        jsonls = {},
        lua_ls = {},
      },
    },
  },
  {
    "williamboman/mason.nvim",
    opts = {
      ensure_installed = {
        -- formatters / linters (LSP servers are handled by mason-lspconfig)
        "prettier", "eslint_d", "stylua", "ruff", "black",
      },
    },
  },
}
