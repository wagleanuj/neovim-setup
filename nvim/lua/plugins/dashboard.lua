-- Disable the snacks dashboard: it fights the auto-opened neo-tree sidebar.
-- With it off, a bare `nvim` opens to an empty editor + the tree (VS Code-like).
-- To get the dashboard back, set enabled = true (and expect to open the tree
-- manually with <leader>e on the start screen).
return {
  {
    "folke/snacks.nvim",
    opts = {
      dashboard = { enabled = false },
    },
  },
}
