-- Keymaps de LSP (se activan al adjuntar a un buffer)
local function on_attach(_, bufnr)
  local map = function(keys, func, desc)
    vim.keymap.set("n", keys, func, { buffer = bufnr, desc = "LSP: " .. desc })
  end

  map("gd",          vim.lsp.buf.definition,       "Ir a definición")
  map("gD",          vim.lsp.buf.declaration,       "Ir a declaración")
  map("gI",          vim.lsp.buf.implementation,    "Ir a implementación")
  map("gy",          vim.lsp.buf.type_definition,   "Ir a tipo")
  map("K",           vim.lsp.buf.hover,             "Hover docs")
  map("gK",          vim.lsp.buf.signature_help,    "Firma")
  map("<leader>ca",  vim.lsp.buf.code_action,       "Acción de código")
  map("<leader>cr",  vim.lsp.buf.rename,            "Renombrar")
  map("<leader>cf",  function() require("conform").format({ async = true }) end, "Formatear")

  -- Snacks los sobreescribirá si está disponible
  map("gr", function()
    local ok, snacks = pcall(require, "snacks")
    if ok then snacks.picker.lsp_references()
    else vim.lsp.buf.references() end
  end, "Referencias")

  map("<leader>ss", function()
    local ok, snacks = pcall(require, "snacks")
    if ok then snacks.picker.lsp_symbols()
    else vim.lsp.buf.document_symbol() end
  end, "Símbolos del documento")
end

return {
  -- LSP Config
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
    },
    config = function()
      -- Diagnósticos visuales
      vim.diagnostic.config({
        underline = true,
        update_in_insert = false,
        virtual_text = { spacing = 4, source = "if_many", prefix = "●" },
        severity_sort = true,
        signs = {
          text = {
            [vim.diagnostic.severity.ERROR] = " ",
            [vim.diagnostic.severity.WARN]  = " ",
            [vim.diagnostic.severity.HINT]  = " ",
            [vim.diagnostic.severity.INFO]  = " ",
          },
        },
      })

      -- Mason: instalador de LSPs
      require("mason").setup({ ui = { border = "rounded" } })

      -- Servidores a instalar y configurar automáticamente
      -- (Java/jdtls lo maneja nvim-jdtls por separado)
      local servers = {
        clangd = {
          cmd = { "clangd", "--background-index", "--clang-tidy", "--header-insertion=iwyu" },
        },
        pyright = {
          settings = {
            python = {
              analysis = { autoSearchPaths = true, diagnosticMode = "workspace" },
            },
          },
        },
        lua_ls = {
          settings = {
            Lua = {
              workspace = { checkThirdParty = false },
              codeLens = { enable = true },
              completion = { callSnippet = "Replace" },
              diagnostics = { globals = { "vim" } },
            },
          },
        },
      }

      require("mason-lspconfig").setup({
        ensure_installed = vim.tbl_keys(servers),
        automatic_installation = true,
      })

      -- Capacidades extendidas con blink.cmp
      local capabilities = vim.lsp.protocol.make_client_capabilities()
      local ok_blink, blink = pcall(require, "blink.cmp")
      if ok_blink then
        capabilities = blink.get_lsp_capabilities(capabilities)
      end

      for name, opts in pairs(servers) do
        opts.on_attach = on_attach
        opts.capabilities = capabilities
        require("lspconfig")[name].setup(opts)
      end
    end,
  },

  -- Instalador de LSPs/linters/formatters
  {
    "williamboman/mason.nvim",
    cmd = "Mason",
    keys = { { "<leader>cm", "<cmd>Mason<cr>", desc = "Mason" } },
    build = ":MasonUpdate",
    opts = {
      ensure_installed = {
        "clangd", "clang-format",
        "pyright", "ruff",
        "lua-language-server", "stylua",
        "jdtls", "google-java-format",
      },
    },
    config = function(_, opts)
      require("mason").setup(opts)
      local mr = require("mason-registry")
      mr.refresh(function()
        for _, tool in ipairs(opts.ensure_installed or {}) do
          local p = mr.get_package(tool)
          if not p:is_installed() then p:install() end
        end
      end)
    end,
  },

  -- Java LSP (nvim-jdtls maneja correctamente el workspace por proyecto)
  {
    "mfussenegger/nvim-jdtls",
    ft = "java",
    config = function()
      local jdtls = require("jdtls")
      local home = vim.env.HOME
      local jdtls_dir = vim.fn.stdpath("data") .. "/mason/packages/jdtls"
      local project_name = vim.fn.fnamemodify(vim.fn.getcwd(), ":p:h:t")
      local workspace_dir = home .. "/.local/share/jdtls-workspaces/" .. project_name

      -- Buscar el launcher JAR
      local launcher = vim.fn.glob(jdtls_dir .. "/plugins/org.eclipse.equinox.launcher_*.jar")
      if launcher == "" then return end  -- jdtls no instalado aún

      -- Detectar OS para config dir
      local os_config
      if vim.fn.has("mac") == 1 then os_config = "mac"
      elseif vim.fn.has("unix") == 1 then os_config = "linux"
      else os_config = "win" end

      local config = {
        cmd = {
          "java",
          "-Declipse.application=org.eclipse.jdt.ls.core.id1",
          "-Dosgi.bundles.defaultStartLevel=4",
          "-Declipse.product=org.eclipse.jdt.ls.core.product",
          "-Dlog.protocol=true",
          "-Dlog.level=ALL",
          "-Xmx1g",
          "--add-modules=ALL-SYSTEM",
          "--add-opens", "java.base/java.util=ALL-UNNAMED",
          "--add-opens", "java.base/java.lang=ALL-UNNAMED",
          "-jar", launcher,
          "-configuration", jdtls_dir .. "/config_" .. os_config,
          "-data", workspace_dir,
        },
        root_dir = require("jdtls.setup").find_root({ ".git", "mvnw", "gradlew", "pom.xml", "build.gradle" }),
        settings = {
          java = {
            eclipse = { downloadSources = true },
            configuration = { updateBuildConfiguration = "interactive" },
            maven = { downloadSources = true },
            implementationsCodeLens = { enabled = true },
            referencesCodeLens = { enabled = true },
          },
        },
        on_attach = on_attach,
      }

      vim.api.nvim_create_autocmd("FileType", {
        pattern = "java",
        callback = function() jdtls.start_or_attach(config) end,
      })
    end,
  },
}
