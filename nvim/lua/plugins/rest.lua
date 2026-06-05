return {
  {
    "mistweaverco/kulala.nvim",
    ft = { "http", "rest" },
    opts = {},
    keys = {
      { "<leader>rs", function() require("kulala").run() end, ft = "http", desc = "Run request" },
      { "<leader>ra", function() require("kulala").run_all() end, ft = "http", desc = "Run all requests" },
      { "<leader>rp", function() require("kulala").jump_prev() end, ft = "http", desc = "Prev request" },
      { "<leader>rn", function() require("kulala").jump_next() end, ft = "http", desc = "Next request" },
    },
  },
}
