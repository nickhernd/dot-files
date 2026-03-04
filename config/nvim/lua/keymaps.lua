local map = vim.keymap.set

-- Movimiento en líneas envueltas
map({ "n", "x" }, "j", "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })
map({ "n", "x" }, "k", "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })

-- Navegación entre ventanas (ctrl + hjkl)
map("n", "<C-h>", "<C-w>h", { desc = "Ventana izquierda", remap = true })
map("n", "<C-j>", "<C-w>j", { desc = "Ventana abajo", remap = true })
map("n", "<C-k>", "<C-w>k", { desc = "Ventana arriba", remap = true })
map("n", "<C-l>", "<C-w>l", { desc = "Ventana derecha", remap = true })

-- Redimensionar ventanas
map("n", "<C-Up>",    "<cmd>resize +2<cr>",          { desc = "Aumentar altura" })
map("n", "<C-Down>",  "<cmd>resize -2<cr>",           { desc = "Reducir altura" })
map("n", "<C-Left>",  "<cmd>vertical resize -2<cr>",  { desc = "Reducir ancho" })
map("n", "<C-Right>", "<cmd>vertical resize +2<cr>",  { desc = "Aumentar ancho" })

-- Mover líneas (alt + j/k)
map("n", "<A-j>", "<cmd>m .+1<cr>==",        { desc = "Mover línea abajo" })
map("n", "<A-k>", "<cmd>m .-2<cr>==",        { desc = "Mover línea arriba" })
map("i", "<A-j>", "<esc><cmd>m .+1<cr>==gi", { desc = "Mover línea abajo" })
map("i", "<A-k>", "<esc><cmd>m .-2<cr>==gi", { desc = "Mover línea arriba" })
map("v", "<A-j>", ":m '>+1<cr>gv=gv",        { desc = "Mover selección abajo" })
map("v", "<A-k>", ":m '<-2<cr>gv=gv",        { desc = "Mover selección arriba" })

-- Buffers
map("n", "<S-h>",      "<cmd>bprevious<cr>",         { desc = "Buffer anterior" })
map("n", "<S-l>",      "<cmd>bnext<cr>",              { desc = "Siguiente buffer" })
map("n", "[b",         "<cmd>bprevious<cr>",          { desc = "Buffer anterior" })
map("n", "]b",         "<cmd>bnext<cr>",              { desc = "Siguiente buffer" })
map("n", "<leader>bb", "<cmd>e #<cr>",                { desc = "Alternar buffer" })
map("n", "<leader>bd", "<cmd>bdelete<cr>",            { desc = "Cerrar buffer" })
map("n", "<leader>bD", "<cmd>%bd|e#|bd#<cr>",         { desc = "Cerrar otros buffers" })

-- Limpiar búsqueda con Esc
map({ "i", "n" }, "<esc>", "<cmd>noh<cr><esc>", { desc = "Limpiar búsqueda" })

-- Guardar con ctrl+s
map({ "i", "x", "n", "s" }, "<C-s>", "<cmd>w<cr><esc>", { desc = "Guardar archivo" })

-- Salir
map("n", "<leader>qq", "<cmd>qa<cr>", { desc = "Salir de todo" })

-- Indentar en modo visual sin perder selección
map("v", "<", "<gv")
map("v", ">", ">gv")

-- Nuevo archivo
map("n", "<leader>fn", "<cmd>enew<cr>", { desc = "Nuevo archivo" })

-- Toggles
map("n", "<leader>uw", function() vim.wo.wrap = not vim.wo.wrap end,                { desc = "Toggle wrap" })
map("n", "<leader>us", function() vim.opt.spell = not vim.opt.spell:get() end,      { desc = "Toggle ortografía" })
map("n", "<leader>un", function()
  vim.opt.number = not vim.opt.number:get()
  vim.opt.relativenumber = not vim.opt.relativenumber:get()
end, { desc = "Toggle números de línea" })
map("n", "<leader>ud", function()
  local current = vim.diagnostic.is_enabled()
  vim.diagnostic.enable(not current)
end, { desc = "Toggle diagnósticos" })

-- Diagnósticos
local function diag_goto(next, severity)
  local go = next and vim.diagnostic.goto_next or vim.diagnostic.goto_prev
  severity = severity and vim.diagnostic.severity[severity] or nil
  return function() go({ severity = severity }) end
end
map("n", "]d",         diag_goto(true),          { desc = "Siguiente diagnóstico" })
map("n", "[d",         diag_goto(false),          { desc = "Diagnóstico anterior" })
map("n", "]e",         diag_goto(true, "ERROR"),  { desc = "Siguiente error" })
map("n", "[e",         diag_goto(false, "ERROR"), { desc = "Error anterior" })
map("n", "]w",         diag_goto(true, "WARN"),   { desc = "Siguiente warning" })
map("n", "[w",         diag_goto(false, "WARN"),  { desc = "Warning anterior" })
map("n", "<leader>cd", vim.diagnostic.open_float, { desc = "Diagnósticos de línea" })

-- Lazy
map("n", "<leader>l", "<cmd>Lazy<cr>", { desc = "Lazy" })

-- Terminal
map("t", "<esc><esc>", "<c-\\><c-n>",        { desc = "Modo normal en terminal" })
map("t", "<C-h>",      "<cmd>wincmd h<cr>",  { desc = "Ventana izquierda" })
map("t", "<C-j>",      "<cmd>wincmd j<cr>",  { desc = "Ventana abajo" })
map("t", "<C-k>",      "<cmd>wincmd k<cr>",  { desc = "Ventana arriba" })
map("t", "<C-l>",      "<cmd>wincmd l<cr>",  { desc = "Ventana derecha" })

-- Abrir terminal flotante (snacks lo sobreescribirá con el suyo)
map("n", "<leader>tt", "<cmd>terminal<cr>",  { desc = "Terminal" })
