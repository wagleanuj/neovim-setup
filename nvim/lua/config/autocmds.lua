-- LazyVim loads this automatically. Keep custom autocmds here.
local aug = vim.api.nvim_create_augroup("UserConfig", { clear = true })

-- highlight on yank
vim.api.nvim_create_autocmd("TextYankPost", {
  group = aug,
  callback = function() vim.highlight.on_yank({ timeout = 150 }) end,
})

-- NOTE: the neo-tree sidebar auto-opens on startup via the neo-tree spec's `init`
-- in lua/plugins/explorer.lua (registered there because config/autocmds.lua is
-- itself loaded lazily, too late to catch VimEnter for a bare `nvim`).
