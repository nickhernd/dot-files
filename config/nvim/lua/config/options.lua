-- Options are automatically loaded before lazy.nvim startup.
require("config.remote_clipboard").setup()

vim.opt.relativenumber = false
vim.g.autoformat = false

-- ---- Portado de tu init.vim ----
vim.opt.relativenumber = true
vim.opt.colorcolumn = "120"
vim.opt.scrolloff = 8
vim.opt.wrap = false
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.swapfile = false
vim.opt.undofile = true
vim.opt.clipboard = "unnamedplus"
vim.opt.spelllang = { "es", "en" }
vim.opt.conceallevel = 2 -- fórmulas LaTeX/Markdown más legibles
vim.filetype.add({ extension = { asm = "nasm", nasm = "nasm", s = "asm", S = "asm", ld = "linkerscript" } })
