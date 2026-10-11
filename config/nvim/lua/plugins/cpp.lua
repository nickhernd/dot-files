-- C/C++ con los proyectos de cpp-new (CMakePresets): compilar/ejecutar/depurar con cmake-tools,
-- ver el ensamblador con Compiler Explorer y depurar hacia atrás grabaciones de rr.
--   <leader>m…  p preset · b compilar · r ejecutar · t tests · d depurar · l objetivo · c limpiar
--               a ensamblador (Compiler Explorer, también con selección) · R reproducir grabación de rr
return {
  {
    "Civitasv/cmake-tools.nvim",
    opts = {
      cmake_regenerate_on_save = true,
      -- Enlaza compile_commands.json del preset activo en la raíz (para clangd)
      cmake_soft_link_compile_commands = true,
      cmake_executor = { name = "quickfix" },
      cmake_runner = { name = "terminal" },
    },
    keys = {
      { "<leader>mp", "<cmd>CMakeSelectConfigurePreset<cr>", desc = "CMake: preset" },
      { "<leader>mb", "<cmd>CMakeBuild<cr>", desc = "CMake: compilar" },
      { "<leader>mr", "<cmd>CMakeRun<cr>", desc = "CMake: ejecutar" },
      { "<leader>mt", "<cmd>CMakeRunTest<cr>", desc = "CMake: tests" },
      { "<leader>md", "<cmd>CMakeDebug<cr>", desc = "CMake: depurar" },
      { "<leader>ml", "<cmd>CMakeSelectLaunchTarget<cr>", desc = "CMake: objetivo a ejecutar" },
      { "<leader>mc", "<cmd>CMakeClean<cr>", desc = "CMake: limpiar" },
    },
  },

  -- Ensamblador generado (manda el código a godbolt.org): <leader>ma en todo el archivo o en una selección
  {
    "krady21/compiler-explorer.nvim",
    cmd = { "CECompile", "CECompileLive", "CEFormat", "CEAddLibrary", "CELoadExample", "CEOpenWebsite" },
    keys = {
      { "<leader>ma", ":CECompile<cr>", mode = { "n", "v" }, desc = "Compiler Explorer: ensamblador" },
      { "<leader>mA", "<cmd>CECompileLive<cr>", desc = "Compiler Explorer: en vivo" },
    },
    opts = {},
  },

  -- rr: graba con `rr record ./build/relwithdeb/programa` y aquí <leader>mR reproduce la última
  -- grabación y engancha el depurador (gdb por DAP): se puede ir hacia atrás (reverse-step/continue
  -- desde la consola de DAP con `-exec reverse-next`, `-exec reverse-continue`...)
  {
    "mfussenegger/nvim-dap",
    opts = function()
      local dap = require("dap")
      dap.adapters.gdb = {
        type = "executable",
        command = "gdb",
        args = { "--interpreter=dap", "--eval-command", "set print pretty on" },
      }
      local rr = {
        name = "rr: reproducir la última grabación",
        type = "gdb",
        request = "attach",
        target = "localhost:50505",
        program = function()
          return vim.fn.input("Ejecutable grabado: ", vim.fn.getcwd() .. "/build/relwithdeb/", "file")
        end,
        cwd = "${workspaceFolder}",
      }
      for _, ft in ipairs({ "c", "cpp" }) do
        dap.configurations[ft] = dap.configurations[ft] or {}
        table.insert(dap.configurations[ft], rr)
      end
      vim.keymap.set("n", "<leader>mR", function()
        Snacks.terminal({ "rr", "replay", "-s", "50505", "-k" }, { interactive = false, win = { position = "bottom", height = 0.25 } })
        vim.defer_fn(function() dap.run(rr) end, 1500)
      end, { desc = "rr: reproducir y depurar" })
    end,
  },
}
