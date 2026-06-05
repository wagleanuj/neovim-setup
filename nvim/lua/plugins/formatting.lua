return {
  {
    "stevearc/conform.nvim",
    opts = {
      format_on_save = { timeout_ms = 2000, lsp_format = "fallback" },
      formatters_by_ft = {
        javascript = { "prettier" },
        typescript = { "prettier" },
        javascriptreact = { "prettier" },
        typescriptreact = { "prettier" },
        vue = { "prettier" },
        css = { "prettier" },
        html = { "prettier" },
        json = { "prettier" },
        yaml = { "prettier" },
        markdown = { "prettier" },
        python = { "ruff_format", "black" },
        go = { "gofmt" },
        rust = { "rustfmt" },
        lua = { "stylua" },
      },
    },
    keys = {
      {
        "<leader>cf",
        function() require("conform").format({ async = true, lsp_format = "fallback" }) end,
        mode = { "n", "v" },
        desc = "Format buffer",
      },
    },
  },
}
