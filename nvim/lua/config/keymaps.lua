-- LazyVim loads this automatically (in addition to its own keymaps).
-- Only bind keys LazyVim leaves free. Plugin-specific keys live in their plugin specs.
local map = vim.keymap.set

-- quick window nav (complements tmux h/j/k/l)
map("n", "<C-h>", "<C-w>h", { desc = "Window left" })
map("n", "<C-j>", "<C-w>j", { desc = "Window down" })
map("n", "<C-k>", "<C-w>k", { desc = "Window up" })
map("n", "<C-l>", "<C-w>l", { desc = "Window right" })
