-- See https://wiki.hypr.land/Configuring/Basics/Monitors/
-- List current monitors and supported resolutions with: hyprctl monitors all

-- Escala 1 (antes 1.5 / GDK 2): todo más compacto. El rice de Quickshell
-- está diseñado para escala 1. Si se queda pequeño prueba 1.25.
hl.env("GDK_SCALE", "1")
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1 })

-- Monitores de sobremesa (de dot-files)
hl.monitor({ output = "DP-4", mode = "1920x1080@60", position = "0x0", scale = 1 })
hl.monitor({ output = "HDMI-A-1", mode = "1920x1080@75", position = "auto-right", scale = 1 })
