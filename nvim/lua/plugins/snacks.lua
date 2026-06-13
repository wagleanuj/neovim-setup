-- Snacks module overrides.
return {
  {
    "folke/snacks.nvim",
    opts = {
      -- Dashboard off: it fights the auto-opened neo-tree sidebar.
      -- A bare `nvim` opens to an empty editor + the tree (VS Code-like).
      dashboard = { enabled = false },

      -- Inline image rendering in the editor (markdown/latex). Works because
      -- the terminal is Ghostty (Kitty graphics protocol). Renders local AND
      -- remote/linked images; needs ImageMagick (installed) + tmux passthrough
      -- (set in tmux/.tmux.conf). Toggle a single image with <leader>im? — see
      -- :h snacks.image; mostly it just renders automatically on markdown.
      image = { enabled = true },
    },
  },
}
