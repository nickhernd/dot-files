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
    opts = { servers = { asm_lsp = {} } },
  },
  {
    "mason-org/mason.nvim",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      if not vim.tbl_contains(opts.ensure_installed, "asm-lsp") then
        table.insert(opts.ensure_installed, "asm-lsp")
      end
    end,
  },
}
