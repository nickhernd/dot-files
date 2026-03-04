return {
  {
    "stevearc/conform.nvim",
    event = { "BufWritePre" },
    cmd = { "ConformInfo" },
    keys = {
      {
        "<leader>cf",
        function() require("conform").format({ async = true, lsp_fallback = true }) end,
        desc = "Formatear archivo",
      },
    },
    opts = {
      formatters_by_ft = {
        c          = { "clang_format" },
        cpp        = { "clang_format" },
        java       = { "google_java_format" },
        python     = { "ruff_format", "ruff_organize_imports" },
        lua        = { "stylua" },
        sh         = { "shfmt" },
        bash       = { "shfmt" },
        json       = { "prettier" },
        yaml       = { "prettier" },
        markdown   = { "prettier" },
      },
      format_on_save = {
        timeout_ms = 3000,
        lsp_fallback = true,
      },
    },
  },
}
