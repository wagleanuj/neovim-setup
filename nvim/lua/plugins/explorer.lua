-- Neo-tree: VS Code-like sidebar file tree.
-- The neo-tree LazyVim extra (imported in config/lazy.lua) provides the plugin
-- and the <leader>e / <leader>E keymaps. This file tunes its behaviour.
return {
  {
    "nvim-neo-tree/neo-tree.nvim",
    -- init runs during early startup (before VimEnter) for ALL launch modes,
    -- so this reliably auto-opens the sidebar even for a bare `nvim`.
    init = function()
      vim.api.nvim_create_autocmd("VimEnter", {
        group = vim.api.nvim_create_augroup("NeoTreeAutoOpen", { clear = true }),
        callback = function()
          local ft = vim.bo.filetype
          if ft == "gitcommit" or ft == "gitrebase" then return end
          vim.defer_fn(function()
            pcall(function()
              require("neo-tree.command").execute({ toggle = true, dir = vim.uv.cwd() })
              vim.cmd("wincmd p") -- keep focus in the editor, not the tree
            end)
          end, 50)
        end,
      })
    end,
    opts = {
      close_if_last_window = false, -- keep the tree even next to the dashboard
      filesystem = {
        follow_current_file = { enabled = true }, -- highlight the file you're editing
        use_libuv_file_watcher = true, -- auto-refresh on disk changes (e.g. Claude edits)
        hijack_netrw_behavior = "open_default", -- opening a dir opens neo-tree
        filtered_items = {
          visible = true, -- show hidden/dotfiles (dimmed), toggle with H
          hide_dotfiles = false,
          hide_gitignored = false,
        },
      },
      window = {
        width = 32,
        position = "left",
      },
    },
  },
}
