-- undotree: visualize and walk the persistent undo history.
-- Pairs with `undofile = true` (set in config/options.lua) so undo survives
-- closing and reopening a file.
return {
  {
    "mbbill/undotree",
    cmd = { "UndotreeToggle", "UndotreeShow" },
    keys = {
      { "<leader>uu", "<cmd>UndotreeToggle<cr>", desc = "Undotree (history)" },
    },
    init = function()
      vim.g.undotree_WindowLayout = 2 -- tree on the left, diff below
      vim.g.undotree_SetFocusWhenToggle = 1
    end,
  },
}
