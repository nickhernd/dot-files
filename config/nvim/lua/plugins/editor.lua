return {
  -- Navegación rápida con s/S (como hop pero más inteligente)
  {
    "folke/flash.nvim",
    event = "VeryLazy",
    opts = {},
    keys = {
      { "s",     mode = { "n", "x", "o" }, function() require("flash").jump() end,              desc = "Flash Jump" },
      { "S",     mode = { "n", "x", "o" }, function() require("flash").treesitter() end,         desc = "Flash Treesitter" },
      { "r",     mode = "o",               function() require("flash").remote() end,             desc = "Flash Remote" },
      { "R",     mode = { "o", "x" },      function() require("flash").treesitter_search() end,  desc = "Flash Treesitter Search" },
      { "<c-s>", mode = { "c" },           function() require("flash").toggle() end,             desc = "Toggle Flash" },
    },
  },

  -- Signos de git en el gutter
  {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPre", "BufNewFile" },
    opts = {
      signs = {
        add          = { text = "▎" },
        change       = { text = "▎" },
        delete       = { text = "" },
        topdelete    = { text = "" },
        changedelete = { text = "▎" },
        untracked    = { text = "▎" },
      },
      on_attach = function(bufnr)
        local gs = package.loaded.gitsigns
        local map = function(mode, keys, func, desc)
          vim.keymap.set(mode, keys, func, { buffer = bufnr, desc = "Git: " .. desc })
        end

        -- Navegar entre hunks
        map("n", "]h", gs.next_hunk,  "Siguiente hunk")
        map("n", "[h", gs.prev_hunk,  "Hunk anterior")

        -- Acciones
        map({ "n", "v" }, "<leader>ghs", ":Gitsigns stage_hunk<CR>",  "Stage hunk")
        map({ "n", "v" }, "<leader>ghr", ":Gitsigns reset_hunk<CR>",  "Reset hunk")
        map("n", "<leader>ghS", gs.stage_buffer,                       "Stage buffer")
        map("n", "<leader>ghu", gs.undo_stage_hunk,                    "Undo stage hunk")
        map("n", "<leader>ghR", gs.reset_buffer,                       "Reset buffer")
        map("n", "<leader>ghp", gs.preview_hunk_inline,                "Preview hunk")
        map("n", "<leader>ghd", gs.diffthis,                           "Diff")
        map("n", "<leader>ghD", function() gs.diffthis("~") end,       "Diff ~")
        map({ "o", "x" }, "ih", ":<C-U>Gitsigns select_hunk<CR>",     "Seleccionar hunk")
      end,
    },
  },

  -- Explorador de archivos zen (editar directorios como buffers)
  {
    "stevearc/oil.nvim",
    dependencies = { "echasnovski/mini.icons" },
    lazy = false,
    opts = {
      default_file_explorer = true,
      columns = { "icon" },
      view_options = {
        show_hidden = false,
      },
      keymaps = {
        ["g?"]    = "actions.show_help",
        ["<CR>"]  = "actions.select",
        ["<C-v>"] = "actions.select_vsplit",
        ["<C-x>"] = "actions.select_split",
        ["<C-t>"] = "actions.select_tab",
        ["<C-p>"] = "actions.preview",
        ["<C-c>"] = "actions.close",
        ["<C-r>"] = "actions.refresh",
        ["-"]     = "actions.parent",
        ["_"]     = "actions.open_cwd",
        ["`"]     = "actions.cd",
        ["~"]     = "actions.tcd",
        ["gs"]    = "actions.change_sort",
        ["gx"]    = "actions.open_external",
        ["g."]    = "actions.toggle_hidden",
        ["g\\"]   = "actions.toggle_trash",
      },
      use_default_keymaps = false,
    },
    keys = {
      { "<leader>e", "<cmd>Oil<cr>",               desc = "Explorador (dir actual)" },
      { "-",         "<cmd>Oil<cr>",               desc = "Explorador (dir actual)" },
      { "<leader>E", function() require("oil").open(vim.fn.getcwd()) end, desc = "Explorador (raíz)" },
    },
  },

  -- Which-key: ayuda contextual de atajos
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {
      preset = "helix",
      spec = {
        { "<leader>b",  group = "buffers" },
        { "<leader>c",  group = "código" },
        { "<leader>f",  group = "archivos" },
        { "<leader>g",  group = "git" },
        { "<leader>gh", group = "hunks" },
        { "<leader>s",  group = "buscar" },
        { "<leader>t",  group = "terminal" },
        { "<leader>u",  group = "ui/toggles" },
        { "<leader>q",  group = "salir" },
        { "]",          group = "siguiente" },
        { "[",          group = "anterior" },
        { "g",          group = "goto" },
        { "gs",         group = "surround" },
      },
    },
    keys = {
      { "<leader>?", function() require("which-key").show({ global = false }) end, desc = "Keymaps del buffer" },
    },
  },
}
