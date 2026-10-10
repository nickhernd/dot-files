-- See https://wiki.hypr.land/Configuring/Basics/Monitors/
-- List current monitors and supported resolutions with: hyprctl monitors all

-- Escala 1 (antes 1.5 / GDK 2): todo más compacto. El rice de Quickshell
-- está diseñado para escala 1. Si se queda pequeño prueba 1.25.
hl.env("GDK_SCALE", "1")
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1 })

-- Lo que cambia entre ordenadores (monitores, tableta...) va en hypr/perfiles/<perfil>.lua.
-- El perfil de esta máquina está en ~/.config/dotfiles/perfil (lo pregunta install.sh;
-- para cambiarlo: ~/dot-files/install.sh --perfil sobremesa|portatil).
local perfiles = { portatil = true, sobremesa = true }
local f = io.open(os.getenv("HOME") .. "/.config/dotfiles/perfil")
local perfil = f and f:read("l") or ""
if f then f:close() end
perfil = perfil:match("^%s*(.-)%s*$")
if not perfiles[perfil] then perfil = "portatil" end
require("hypr.perfiles." .. perfil)
