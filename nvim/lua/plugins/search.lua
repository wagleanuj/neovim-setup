-- grug-far: project-wide find & replace UI (the VS Code "Search" panel).
-- Complements the file/grep pickers (which only FIND) with interactive replace.
return {
  {
    "MagicDuck/grug-far.nvim",
    cmd = "GrugFar",
    opts = {},
    keys = {
      {
        "<leader>sr",
        function() require("grug-far").open() end,
        mode = { "n" },
        desc = "Search & replace (project)",
      },
      {
        "<leader>sr",
        function() require("grug-far").open({ visualSelectionUsage = "operate-within-range" }) end,
        mode = { "v" },
        desc = "Search & replace (selection)",
      },
      {
        "<leader>sw",
        function() require("grug-far").open({ prefills = { search = vim.fn.expand("<cword>") } }) end,
        desc = "Search & replace word under cursor",
      },
    },
  },
}
