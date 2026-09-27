-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

-- ---- Portado de tu init.vim ----
-- Quitar espacios al final al guardar (excepto markdown, donde significan salto de línea)
vim.api.nvim_create_autocmd("BufWritePre", {
  callback = function(ev)
    if vim.bo[ev.buf].filetype ~= "markdown" then
      local view = vim.fn.winsaveview()
      vim.cmd([[silent! %s/\s\+$//e]])
      vim.fn.winrestview(view)
    end
  end,
})

-- Corrector ortográfico (es/en) en texto, LaTeX, Typst y Markdown
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "tex", "typst", "markdown", "text", "gitcommit" },
  callback = function() vim.opt_local.spell = true; vim.opt_local.wrap = true end,
})
