-- Sistema de temas con selector
-- <leader>ft → elegir tema en cualquier momento
-- El tema elegido se guarda y se restaura en el próximo inicio

local theme_file = vim.fn.stdpath("data") .. "/selected_theme"

local themes = {
  { id = "catppuccin-mocha",     name = "Catppuccin Mocha    (oscuro, púrpura)" },
  { id = "catppuccin-macchiato", name = "Catppuccin Macchiato (oscuro, suave)" },
  { id = "catppuccin-frappe",    name = "Catppuccin Frappé    (medio, frío)" },
  { id = "catppuccin-latte",     name = "Catppuccin Latte     (claro)" },
  { id = "tokyonight-night",     name = "Tokyo Night          (oscuro, azul)" },
  { id = "tokyonight-storm",     name = "Tokyo Storm          (oscuro, nublado)" },
  { id = "tokyonight-moon",      name = "Tokyo Moon           (oscuro, suave)" },
  { id = "tokyonight-day",       name = "Tokyo Day            (claro)" },
  { id = "rose-pine",            name = "Rose Pine            (oscuro, rosa)" },
  { id = "rose-pine-moon",       name = "Rose Pine Moon       (oscuro, frío)" },
  { id = "rose-pine-dawn",       name = "Rose Pine Dawn       (claro)" },
  { id = "gruvbox",              name = "Gruvbox Dark         (retro, cálido)" },
  { id = "kanagawa-wave",        name = "Kanagawa Wave        (japonés, oscuro)" },
  { id = "kanagawa-dragon",      name = "Kanagawa Dragon      (japonés, más oscuro)" },
  { id = "dracula",              name = "Dracula              (oscuro, morado)" },
}

local function save_theme(id)
  local f = io.open(theme_file, "w")
  if f then f:write(id); f:close() end
end

local function load_theme()
  local f = io.open(theme_file, "r")
  if f then
    local id = f:read("*l"); f:close(); return id
  end
end

local function apply(id)
  local ok, err = pcall(vim.cmd.colorscheme, id)
  if not ok then
    vim.notify("Tema no disponible: " .. id .. "\n" .. err, vim.log.levels.WARN)
  end
end

local function select_theme()
  local names = vim.tbl_map(function(t) return t.name end, themes)
  vim.ui.select(names, { prompt = "  Elegir tema" }, function(_, idx)
    if idx then
      apply(themes[idx].id)
      save_theme(themes[idx].id)
      vim.notify("Tema: " .. themes[idx].name:match("^(%S+%s+%S+)"))
    end
  end)
end

-- Al iniciar: cargar tema guardado (o pedir uno si es la primera vez)
vim.api.nvim_create_autocmd("VimEnter", {
  once = true,
  callback = vim.schedule_wrap(function()
    local saved = load_theme()
    if saved then
      apply(saved)
    else
      select_theme()
    end
  end),
})

-- <leader>ft → selector de tema en cualquier momento
vim.keymap.set("n", "<leader>ft", select_theme, { desc = "Elegir tema" })

-- <leader>fT → resetear tema (mostrará el selector al próximo inicio)
vim.keymap.set("n", "<leader>fT", function()
  os.remove(theme_file)
  vim.notify("Tema reseteado. Se pedirá uno al próximo inicio.")
end, { desc = "Resetear tema" })

return {
  -- Catppuccin (mocha / macchiato / frappe / latte)
  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    opts = {
      integrations = {
        blink_cmp  = true,
        gitsigns   = true,
        mini       = { enabled = true },
        treesitter = true,
        which_key  = true,
      },
    },
    config = function(_, opts)
      require("catppuccin").setup(opts)
    end,
  },

  -- Tokyo Night (night / storm / moon / day)
  {
    "folke/tokyonight.nvim",
    priority = 1000,
    opts = { transparent = false },
  },

  -- Rose Pine (main / moon / dawn)
  {
    "rose-pine/neovim",
    name = "rose-pine",
    priority = 1000,
    opts = {},
  },

  -- Gruvbox
  {
    "ellisonleao/gruvbox.nvim",
    priority = 1000,
    opts = { contrast = "hard" },
  },

  -- Kanagawa (wave / dragon / lotus)
  {
    "rebelot/kanagawa.nvim",
    priority = 1000,
    opts = {},
  },

  -- Dracula
  {
    "Mofiqul/dracula.nvim",
    priority = 1000,
  },
}
