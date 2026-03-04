local function augroup(name)
  return vim.api.nvim_create_augroup("minimal_" .. name, { clear = true })
end

-- Resaltar texto al copiar
vim.api.nvim_create_autocmd("TextYankPost", {
  group = augroup("yank_highlight"),
  callback = function() vim.highlight.on_yank() end,
})

-- Volver a la última posición del cursor al abrir un archivo
vim.api.nvim_create_autocmd("BufReadPost", {
  group = augroup("last_position"),
  callback = function(ev)
    local mark = vim.api.nvim_buf_get_mark(ev.buf, '"')
    local line_count = vim.api.nvim_buf_line_count(ev.buf)
    if mark[1] > 0 and mark[1] <= line_count then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
})

-- Cerrar ciertos tipos de ventana con q
vim.api.nvim_create_autocmd("FileType", {
  group = augroup("close_with_q"),
  pattern = {
    "help", "lspinfo", "man", "notify", "qf",
    "spectre_panel", "startuptime", "tsplayground",
    "checkhealth", "oil",
  },
  callback = function(ev)
    vim.bo[ev.buf].buflisted = false
    vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = ev.buf, silent = true })
  end,
})

-- Auto-crear directorios al guardar
vim.api.nvim_create_autocmd("BufWritePre", {
  group = augroup("auto_create_dir"),
  callback = function(ev)
    if ev.match:match("^%w%w+://") then return end
    local file = vim.loop.fs_realpath(ev.match) or ev.match
    vim.fn.mkdir(vim.fn.fnamemodify(file, ":p:h"), "p")
  end,
})

-- Quitar espacios al final de línea al guardar
vim.api.nvim_create_autocmd("BufWritePre", {
  group = augroup("trailing_whitespace"),
  callback = function()
    local pos = vim.api.nvim_win_get_cursor(0)
    vim.cmd([[%s/\s\+$//e]])
    vim.api.nvim_win_set_cursor(0, pos)
  end,
})

-- Envolver y habilitar spell en archivos de texto/markdown
vim.api.nvim_create_autocmd("FileType", {
  group = augroup("wrap_spell"),
  pattern = { "gitcommit", "markdown" },
  callback = function()
    vim.opt_local.wrap = true
    vim.opt_local.spell = true
  end,
})
