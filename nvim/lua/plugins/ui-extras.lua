-- Small editor UI niceties that are purely additive.
return {
  -- treesitter-context: "sticky scroll" — pins the enclosing function/class to
  -- the top of the window while you scroll through a long body.
  {
    "nvim-treesitter/nvim-treesitter-context",
    event = "BufReadPost",
    opts = { max_lines = 3, multiline_threshold = 1 },
    keys = {
      {
        "<leader>uc",
        function() require("treesitter-context").toggle() end,
        desc = "Toggle sticky context",
      },
    },
  },

  -- colorizer: render #rrggbb / rgb() / tailwind color names as live swatches.
  {
    "NvChad/nvim-colorizer.lua",
    event = "BufReadPost",
    opts = {
      filetypes = { "css", "scss", "html", "javascript", "typescript", "javascriptreact", "typescriptreact", "vue", "lua" },
      user_default_options = { tailwind = true, css = true, names = false },
    },
  },
}
