-- vim-tmux-navigator: one set of C-h/j/k/l that crosses the nvim<->tmux boundary.
-- Inside nvim it moves between splits; at the edge of nvim it hands off to the
-- adjacent tmux pane (and vice-versa). The matching tmux side lives in
-- tmux/.tmux.conf (the christoomey/vim-tmux-navigator tpm plugin).
-- NOTE: this replaces the manual C-h/j/k/l window maps that used to be in
-- config/keymaps.lua.
return {
  {
    "christoomey/vim-tmux-navigator",
    cmd = {
      "TmuxNavigateLeft",
      "TmuxNavigateDown",
      "TmuxNavigateUp",
      "TmuxNavigateRight",
      "TmuxNavigatePrevious",
    },
    keys = {
      { "<C-h>", "<cmd>TmuxNavigateLeft<cr>", desc = "Go to left window/pane" },
      { "<C-j>", "<cmd>TmuxNavigateDown<cr>", desc = "Go to lower window/pane" },
      { "<C-k>", "<cmd>TmuxNavigateUp<cr>", desc = "Go to upper window/pane" },
      { "<C-l>", "<cmd>TmuxNavigateRight<cr>", desc = "Go to right window/pane" },
    },
  },
}
