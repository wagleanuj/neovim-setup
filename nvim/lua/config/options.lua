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
