-- Standalone linters (nvim-lint) for tools that aren't LSP servers.
-- LSP diagnostics (pyright/ruff/gopls/etc.) still come from lsp.lua; this layers
-- on file-type linters VS Code users expect: shellcheck for the bash scripts in
-- this very repo, hadolint for Dockerfiles, markdownlint, yamllint, golangci-lint.
return {
  {
    "mfussenegger/nvim-lint",
    event = { "BufReadPost", "BufWritePost", "InsertLeave" },
    config = function()
      local lint = require("lint")
      lint.linters_by_ft = {
        sh = { "shellcheck" },
        bash = { "shellcheck" },
        zsh = { "shellcheck" },
        dockerfile = { "hadolint" },
        markdown = { "markdownlint" },
        yaml = { "yamllint" },
        go = { "golangcilint" },
      }
      local aug = vim.api.nvim_create_augroup("NvimLint", { clear = true })
      vim.api.nvim_create_autocmd({ "BufReadPost", "BufWritePost", "InsertLeave" }, {
        group = aug,
        callback = function()
          -- only lint modifiable, real-file buffers
          if vim.bo.modifiable and vim.bo.buftype == "" then
            lint.try_lint()
          end
        end,
      })
    end,
  },
  -- make sure the linter binaries are present
  {
    "mason-org/mason.nvim",
    opts = {
      ensure_installed = {
        "shellcheck", "hadolint", "markdownlint", "yamllint", "golangci-lint",
      },
    },
  },
}
