-- Bajo nivel: ensamblador, volcados de objdump, linker scripts y device trees
return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      vim.list_extend(opts.ensure_installed, { "asm", "nasm", "objdump", "linkerscript", "devicetree", "make", "c", "cpp" })
    end,
  },
  {
    "neovim/nvim-lspconfig",
    -- asm-lsp viene del sistema (AUR, instalar-perfil.sh): Mason lo compilaría con Rust
    opts = { servers = { asm_lsp = { mason = false } } },
  },
}
