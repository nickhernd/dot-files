return {
  -- Auto-guardado (como tu init.vim: guarda solo tras unos segundos sin tocar nada)
  {
    "okuuva/auto-save.nvim",
    event = { "InsertLeave", "TextChanged" },
    opts = { debounce_delay = 15000 },
  },

  -- Extra para Mason (los LSP de cada lenguaje ya los piden los extras de LazyVim)
  {
    "mason-org/mason.nvim",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      if not vim.tbl_contains(opts.ensure_installed, "shellcheck") then
        table.insert(opts.ensure_installed, "shellcheck")
      end
    end,
  },

  -- Typst: vista previa en vivo en el navegador (:TypstPreview)
  {
    "chomosuke/typst-preview.nvim",
    ft = "typst",
    version = "1.*",
    opts = {},
  },

  -- LaTeX: vimtex con zathura como visor (compila con \ll, ve el PDF con \lv)
  {
    "lervag/vimtex",
    init = function()
      vim.g.vimtex_view_method = "zathura"
    end,
  },
}
