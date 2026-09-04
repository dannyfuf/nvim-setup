-- Prepend rbenv shims so Mason and other tools pick up the rbenv-managed Ruby
-- instead of the macOS system Ruby, which is only 2.6.
vim.env.PATH = vim.env.HOME .. "/.rbenv/shims:" .. vim.env.HOME .. "/.rbenv/bin:" .. vim.env.PATH

local opt = vim.opt
opt.number = true

opt.tabstop = 2
opt.shiftwidth = 2
opt.expandtab = true
opt.autoindent = true

opt.wrap = false

opt.cursorline = true
