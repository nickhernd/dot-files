return {
  {
    "folke/snacks.nvim",
    priority = 1000,
    lazy = false,
    opts = {
      -- Fuzzy picker (reemplaza telescope)
      picker = { enabled = true },

      -- Notificaciones (reemplaza noice parcialmente)
      notifier = {
        enabled = true,
        timeout = 3000,
        style = "compact",
      },

      -- Resaltar palabra bajo cursor
      words = { enabled = true },

      -- Manejo de archivos grandes (deshabilita plugins pesados)
      bigfile = { enabled = true },

      -- Integración con lazygit
      lazygit = { enabled = true },

      -- Git (blame, etc.)
      git = { enabled = true },

      -- Dashboard desactivado (zen = sin pantalla de bienvenida)
      dashboard = { enabled = false },

      -- Statuscolumn desactivado (usamos signcolumn estándar)
      statuscolumn = { enabled = false },

      -- Smooth scroll (opcional)
      scroll = { enabled = false },
    },
    keys = {
      -- Archivos
      { "<leader>ff", function() Snacks.picker.files() end,          desc = "Buscar archivos" },
      { "<leader>fr", function() Snacks.picker.recent() end,         desc = "Archivos recientes" },
      { "<leader>fb", function() Snacks.picker.buffers() end,        desc = "Buffers" },
      { "<leader>fn", "<cmd>enew<cr>",                               desc = "Nuevo archivo" },

      -- Búsqueda
      { "<leader>/",  function() Snacks.picker.grep() end,           desc = "Grep en proyecto" },
      { "<leader>sg", function() Snacks.picker.grep() end,           desc = "Grep" },
      { "<leader>sw", function() Snacks.picker.grep_word() end,      desc = "Buscar palabra" },
      { "<leader>s/", function() Snacks.picker.grep_buffers() end,   desc = "Grep en buffers" },

      -- Búsquedas varias
      { "<leader>sh", function() Snacks.picker.help() end,           desc = "Ayuda" },
      { "<leader>sk", function() Snacks.picker.keymaps() end,        desc = "Keymaps" },
      { "<leader>sd", function() Snacks.picker.diagnostics() end,    desc = "Diagnósticos" },
      { "<leader>sc", function() Snacks.picker.command_history() end,desc = "Historial de comandos" },
      { "<leader>sm", function() Snacks.picker.marks() end,          desc = "Marcas" },
      { '<leader>s"', function() Snacks.picker.registers() end,      desc = "Registros" },

      -- LSP (picker)
      { "gr",         function() Snacks.picker.lsp_references() end,         desc = "LSP: Referencias" },
      { "<leader>ss", function() Snacks.picker.lsp_symbols() end,            desc = "LSP: Símbolos" },
      { "<leader>sS", function() Snacks.picker.lsp_workspace_symbols() end,  desc = "LSP: Símbolos workspace" },

      -- Git
      { "<leader>gg", function() Snacks.lazygit() end,               desc = "Lazygit" },
      { "<leader>gb", function() Snacks.git.blame_line() end,        desc = "Git blame" },
      { "<leader>gc", function() Snacks.picker.git_log() end,        desc = "Git log" },
      { "<leader>gf", function() Snacks.picker.git_log_file() end,   desc = "Git log (archivo)" },
      { "<leader>gs", function() Snacks.picker.git_status() end,     desc = "Git status" },

      -- Notificaciones
      { "<leader>un", function() Snacks.notifier.hide() end,         desc = "Cerrar notificaciones" },
      { "<leader>sN", function() Snacks.picker.notifications() end,  desc = "Historial notificaciones" },

      -- Terminal flotante
      { "<leader>tt", function() Snacks.terminal() end,              desc = "Terminal flotante" },
      { "<c-/>",      function() Snacks.terminal() end,              mode = { "n", "t" }, desc = "Terminal flotante" },
    },
    init = function()
      vim.api.nvim_create_autocmd("User", {
        pattern = "VeryLazy",
        callback = function()
          -- Global Snacks accesible como `Snacks.*`
          _G.Snacks = require("snacks")
        end,
      })
    end,
  },
}
