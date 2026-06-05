-- LazyVim loads this automatically. Keep custom autocmds here.
local aug = vim.api.nvim_create_augroup("UserConfig", { clear = true })

-- highlight on yank
vim.api.nvim_create_autocmd("TextYankPost", {
  group = aug,
  callback = function() vim.highlight.on_yank({ timeout = 150 }) end,
})
