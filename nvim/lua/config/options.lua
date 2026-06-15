-- LazyVim loads this automatically. mapleader must be set before lazy (LazyVim sets it),
-- but we keep explicit values for clarity.
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

local opt = vim.opt
opt.relativenumber = true
opt.number = true
opt.scrolloff = 8
opt.signcolumn = "yes"
opt.wrap = false
opt.expandtab = true
opt.shiftwidth = 2
opt.tabstop = 2
opt.termguicolors = true

-- persistent undo: undo history survives closing/reopening a file (pairs with undotree)
opt.undofile = true
opt.undolevels = 10000

-- Remote/SSH clipboard: Neovim 0.11 auto-uses the OSC52 escape sequence when
-- $SSH_TTY is set and no system clipboard tool is found, so yanks on a remote
-- box reach your LOCAL clipboard (Ghostty/Kitty/WezTerm support OSC52). Nothing
-- to configure for that. Locally, LazyVim already syncs the system clipboard.
