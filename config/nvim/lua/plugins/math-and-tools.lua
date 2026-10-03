-- Extras para matemáticas, REPL y git
return {
  -- Snippets de LaTeX para escribir mates rápido (también en Markdown):
  --   mk -> $ $ (inline)   dm -> bloque   ff -> \frac{}{}   sr -> ^2   @a -> \alpha ...
  {
    "iurimateus/luasnip-latex-snippets.nvim",
    ft = { "tex", "markdown" },
    dependencies = { "L3MON4D3/LuaSnip", "lervag/vimtex" },
    config = function()
      require("luasnip-latex-snippets").setup({ use_treesitter = true, allow_on_markdown = true })
      require("luasnip").config.setup({ enable_autosnippets = true })
    end,
  },

  -- Imágenes y fórmulas renderizadas dentro de Neovim (en kitty): LaTeX en
  -- Markdown, imágenes de los .md, PDFs/PNGs al abrirlos.
  {
    "folke/snacks.nvim",
    opts = {
      image = {
        enabled = true,
        math = { enabled = true, latex = { font_size = "large" } },
        doc = { inline = false, float = true },
      },
    },
  },

  -- REPL: manda líneas/selecciones a IPython (Python), Julia, Lean... como un notebook
  --   <leader>jo abre la REPL, <leader>jl manda la línea, <leader>jc selección/movimiento, <leader>jf el archivo
  {
    "Vigemus/iron.nvim",
    cmd = { "IronRepl", "IronRestart", "IronFocus", "IronHide" },
    keys = {
      { "<leader>jo", "<cmd>IronRepl<cr>", desc = "REPL: abrir" },
      { "<leader>jr", "<cmd>IronRestart<cr>", desc = "REPL: reiniciar" },
      { "<leader>jl", desc = "REPL: enviar línea" },
      { "<leader>jc", mode = { "n", "v" }, desc = "REPL: enviar selección/movimiento" },
      { "<leader>jf", desc = "REPL: enviar archivo" },
    },
    config = function()
      local view = require("iron.view")
      require("iron.core").setup({
        config = {
          scratch_repl = true,
          repl_definition = {
            python = { command = { "ipython", "--no-autoindent" }, format = require("iron.fts.common").bracketed_paste_python },
            sh = { command = { "bash" } },
          },
          repl_open_cmd = view.split.vertical.botright(0.4),
        },
        keymaps = {
          send_line = "<leader>jl",
          send_motion = "<leader>jc",
          visual_send = "<leader>jc",
          send_file = "<leader>jf",
          clear = "<leader>jx",
          exit = "<leader>jq",
        },
      })
    end,
  },

  -- Git: ver diffs e historial de un archivo (<leader>gD diff, <leader>gH historial)
  {
    "sindrets/diffview.nvim",
    cmd = { "DiffviewOpen", "DiffviewFileHistory" },
    keys = {
      { "<leader>gD", "<cmd>DiffviewOpen<cr>", desc = "Diffview: cambios" },
      { "<leader>gH", "<cmd>DiffviewFileHistory %<cr>", desc = "Diffview: historial del archivo" },
    },
  },

  -- LaTeX: ocultar comandos para leer las fórmulas mejor (\alpha -> α)
  {
    "lervag/vimtex",
    init = function()
      vim.g.vimtex_syntax_conceal_disable = 0
    end,
  },
}
