return {
  -- oil: edit the filesystem like a buffer
  {
    "stevearc/oil.nvim",
    opts = {
      default_file_explorer = true,
      view_options = { show_hidden = true },
      keymaps = { ["q"] = "actions.close" },
    },
    keys = {
      { "-", "<cmd>Oil<cr>", desc = "Open parent dir (oil)" },
    },
    lazy = false,
  },

  -- trouble: diagnostics / references list
  {
    "folke/trouble.nvim",
    opts = {},
    keys = {
      { "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>", desc = "Diagnostics (Trouble)" },
      { "<leader>xX", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>", desc = "Buffer Diagnostics" },
      { "<leader>xr", "<cmd>Trouble lsp_references toggle<cr>", desc = "LSP References" },
      { "<leader>xq", "<cmd>Trouble qflist toggle<cr>", desc = "Quickfix List" },
    },
  },
}
