return {
  -- Colección de plugins pequeños y rápidos
  {
    "echasnovski/mini.nvim",
    version = false,
    event = "VeryLazy",
    config = function()
      -- Pares automáticos: () [] {} "" ''
      require("mini.pairs").setup()

      -- Objetos de texto mejorados: a( i[ a{ etc.
      require("mini.ai").setup({ n_lines = 500 })

      -- Iconos (mini.icons es más ligero que nvim-web-devicons)
      require("mini.icons").setup()

      -- Statusline minimalista (reemplaza lualine)
      local statusline = require("mini.statusline")
      statusline.setup({
        use_icons = true,
        content = {
          active = function()
            local mode, mode_hl = statusline.section_mode({ trunc_width = 120 })
            local git         = statusline.section_git({ trunc_width = 75 })
            local diagnostics = statusline.section_diagnostics({ trunc_width = 75 })
            local filename    = statusline.section_filename({ trunc_width = 140 })
            local fileinfo    = statusline.section_fileinfo({ trunc_width = 120 })
            local location    = statusline.section_location({ trunc_width = 75 })

            return statusline.combine_groups({
              { hl = mode_hl,            strings = { mode } },
              { hl = "MiniStatuslineDevinfo", strings = { git, diagnostics } },
              "%<", -- truncar aquí si no hay espacio
              { hl = "MiniStatuslineFilename", strings = { filename } },
              "%=", -- alinear derecha
              { hl = "MiniStatuslineFileinfo", strings = { fileinfo } },
              { hl = mode_hl,            strings = { location } },
            })
          end,
        },
      })

      -- Surround: agregar/cambiar/borrar rodeos (ys, cs, ds)
      require("mini.surround").setup({
        mappings = {
          add            = "gsa",
          delete         = "gsd",
          find           = "gsf",
          find_left      = "gsF",
          highlight      = "gsh",
          replace        = "gsr",
          update_n_lines = "gsn",
        },
      })
    end,
  },
}
