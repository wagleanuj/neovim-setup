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
        bashls = {},        -- shell scripts (this repo's install.sh / bin/dev)
        terraformls = {},   -- terraform / HCL
        taplo = {},         -- TOML (Cargo.toml, pyproject.toml, etc.)
        clangd = {},        -- C / C++
      },
    },
  },
  {
    "mason-org/mason.nvim",
    opts = {
      ensure_installed = {
        -- formatters / linters (LSP servers are handled by mason-lspconfig)
        "prettier", "eslint_d", "stylua", "ruff", "black",
      },
    },
  },
}
