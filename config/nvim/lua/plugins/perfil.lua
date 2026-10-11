-- Mi perfil: verificación (cppcheck + MISRA, TLA+), FPGA (verible), corrector en
-- español para el TFG (ltex-ls-plus). Java va con el extra lang.java de LazyVim (jdtls);
-- clang-tidy ya lo pasa clangd (extra lang.clangd) y asm-lsp está en lowlevel.lua.

-- MISRA en cppcheck: <leader>cM lo activa/desactiva (sin el texto de las reglas,
-- que es de pago, cppcheck da solo el número de regla)
vim.g.misra = false

return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      vim.list_extend(opts.ensure_installed, { "systemverilog", "tlaplus", "java" })
      -- Neovim llama "tla" a los .tla; el parser se llama tlaplus
      vim.treesitter.language.register("tlaplus", "tla")
    end,
  },

  {
    "mason-org/mason.nvim",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      for _, p in ipairs({ "verible", "ltex-ls-plus" }) do
        if not vim.tbl_contains(opts.ensure_installed, p) then
          table.insert(opts.ensure_installed, p)
        end
      end
    end,
  },

  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        -- SystemVerilog/Verilog: diagnósticos, ir a definición y formato (<leader>cf)
        verible = {},
        -- Gramática y ortografía (español; detecta inglés en los párrafos que lo sean)
        ltex_plus = {
          filetypes = { "tex", "bib", "markdown", "typst", "gitcommit" },
          settings = {
            ltex = {
              language = "es",
              additionalRules = { motherTongue = "es" },
              checkFrequency = "save",
            },
          },
        },
      },
    },
  },

  {
    "mfussenegger/nvim-lint",
    opts = {
      linters_by_ft = {
        c = { "cppcheck" },
        cpp = { "cppcheck" },
      },
      linters = {
        cppcheck = {
          prepend_args = {
            function()
              return vim.g.misra and "--addon=misra" or nil
            end,
          },
        },
      },
    },
    keys = {
      {
        "<leader>cM",
        function()
          vim.g.misra = not vim.g.misra
          require("lint").try_lint()
          vim.notify("MISRA en cppcheck: " .. (vim.g.misra and "activado" or "desactivado"))
        end,
        desc = "cppcheck: MISRA on/off",
      },
    },
  },

  -- TLA+ (localleader = \): \m pasa TLC al archivo (necesita un .cfg al lado con el mismo nombre),
  -- \p traduce PlusCal y \s comprueba la sintaxis (SANY)
  {
    "folke/snacks.nvim",
    keys = {
      { "<localleader>m", function() Snacks.terminal({ "tlc", vim.fn.expand("%:p") }, { cwd = vim.fn.expand("%:p:h"), interactive = false }) end, desc = "TLA+: TLC (model check)", ft = "tla" },
      { "<localleader>p", function() vim.cmd("write | silent !tlc --pcal %") vim.cmd("edit!") end, desc = "TLA+: traducir PlusCal", ft = "tla" },
      { "<localleader>s", function() Snacks.terminal({ "tlc", "--sany", vim.fn.expand("%:p") }, { interactive = false }) end, desc = "TLA+: sintaxis (SANY)", ft = "tla" },
    },
  },
}
