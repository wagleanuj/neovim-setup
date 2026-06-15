-- Code structure: symbols outline (aerial) + breadcrumb winbar (barbecue).
-- aerial  = the VS Code "Outline" panel (functions/classes for the current file).
-- barbecue = the VS Code breadcrumb trail at the top of the window.
return {
  {
    "stevearc/aerial.nvim",
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "nvim-tree/nvim-web-devicons",
    },
    cmd = { "AerialToggle", "AerialOpen" },
    opts = {
      layout = { default_direction = "right", min_width = 30 },
      attach_mode = "global",
    },
    keys = {
      { "<leader>co", "<cmd>AerialToggle<cr>", desc = "Outline (symbols)" },
    },
  },
  {
    "utilyre/barbecue.nvim",
    name = "barbecue",
    version = "*",
    event = "BufReadPost",
    dependencies = {
      "SmiteshP/nvim-navic",
      "nvim-tree/nvim-web-devicons",
    },
    opts = {
      attach_navic = true, -- let LazyVim's lspconfig hand symbols to navic
      show_modified = true,
    },
  },
}
