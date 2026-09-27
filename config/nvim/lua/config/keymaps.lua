-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- ---- Portado de tu init.vim ----
local map = vim.keymap.set

-- Buscar texto (live grep) y palabra bajo el cursor en todo el proyecto
map("n", "<leader>fg", function() Snacks.picker.grep() end, { desc = "Buscar texto (grep)" })
map("n", "<leader>fw", function() Snacks.picker.grep_word() end, { desc = "Buscar palabra bajo cursor" })
-- Elegir tema
map("n", "<leader>ft", function() Snacks.picker.colorschemes() end, { desc = "Elegir tema" })
-- Reemplazar palabra bajo el cursor en el archivo
map("n", "<leader>r", [[:%s/\<<C-r><C-w>\>//g<Left><Left>]], { desc = "Reemplazar palabra" })
-- Terminal a la derecha
map("n", "<leader>t", "<cmd>vsplit | terminal<cr>i", { desc = "Terminal a la derecha" })

-- Navegar splits con Ctrl+flechas, redimensionar con Shift+flechas
map("n", "<C-Left>", "<C-w>h")
map("n", "<C-Right>", "<C-w>l")
map("n", "<C-Down>", "<C-w>j")
map("n", "<C-Up>", "<C-w>k")
map("n", "<S-Left>", "<cmd>vertical resize -3<cr>")
map("n", "<S-Right>", "<cmd>vertical resize +3<cr>")
map("n", "<S-Up>", "<cmd>resize +3<cr>")
map("n", "<S-Down>", "<cmd>resize -3<cr>")

-- Mover selección con J/K
map("v", "J", ":m '>+1<cr>gv=gv", { silent = true })
map("v", "K", ":m '<-2<cr>gv=gv", { silent = true })

-- Portapapeles estilo estándar
map("v", "<C-c>", '"+y')
map("v", "<C-x>", '"+x')
map("i", "<C-v>", "<C-r>+")
