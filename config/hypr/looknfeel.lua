-- Look del rice dhrruvsharma/shell, algo más contenido.
-- Colores generados por matugen desde el wallpaper -> hypr/colors.lua
local ok, colors = pcall(require, "hypr.colors")
if not ok then colors = nil end

hl.config({
  general = {
    gaps_in = 4,
    gaps_out = 10,
    border_size = 2,
    resize_on_border = true,
    layout = "dwindle",
  },

  decoration = {
    rounding = 14,
    rounding_power = 2,
    active_opacity = 0.97,
    inactive_opacity = 0.90,
    fullscreen_opacity = 1.0,

    shadow = {
      enabled = true,
      range = 14,
      render_power = 4,
    },

    blur = {
      enabled = true,
      size = 8,
      passes = 3,
      ignore_opacity = true,
      new_optimizations = true,
    },
  },

  animations = { enabled = true },

  misc = {
    disable_hyprland_logo = true,
    disable_splash_rendering = true,
    force_default_wallpaper = 0,
  },
})

if colors then
  hl.config({
    general = {
      col = {
        active_border = { colors = { colors.primary, colors.tertiary }, angle = 45 },
        inactive_border = { colors = { colors.surface_container, colors.outline }, angle = 45 },
      },
    },
    decoration = { shadow = { color = colors.shadow } },
  })
end

hl.curve("easeOutQuint", { type = "bezier", points = { { 0.23, 1 }, { 0.32, 1 } } })
hl.curve("linear", { type = "bezier", points = { { 0, 0 }, { 1, 1 } } })
hl.curve("almostLinear", { type = "bezier", points = { { 0.5, 0.5 }, { 0.75, 1.0 } } })
hl.curve("quick", { type = "bezier", points = { { 0.15, 0 }, { 0.1, 1 } } })
hl.curve("bounceCurve", { type = "bezier", points = { { 0.6, 1.5 }, { 0.8, 1 } } })

hl.animation({ leaf = "global", enabled = true, speed = 10, bezier = "default" })
hl.animation({ leaf = "border", enabled = true, speed = 5.39, bezier = "easeOutQuint" })
hl.animation({ leaf = "windows", enabled = true, speed = 4.79, bezier = "bounceCurve" })
hl.animation({ leaf = "windowsIn", enabled = true, speed = 4.5, bezier = "bounceCurve", style = "slide 10%" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 4.5, bezier = "linear", style = "popin 87%" })
hl.animation({ leaf = "fadeIn", enabled = true, speed = 1.73, bezier = "almostLinear" })
hl.animation({ leaf = "fadeOut", enabled = true, speed = 1.46, bezier = "almostLinear" })
hl.animation({ leaf = "fade", enabled = true, speed = 3.03, bezier = "quick" })
hl.animation({ leaf = "layers", enabled = true, speed = 3.81, bezier = "easeOutQuint" })
hl.animation({ leaf = "layersIn", enabled = true, speed = 4, bezier = "easeOutQuint", style = "fade" })
hl.animation({ leaf = "layersOut", enabled = true, speed = 1.5, bezier = "linear", style = "fade" })
hl.animation({ leaf = "workspaces", enabled = true, speed = 4.5, bezier = "bounceCurve", style = "slidefadevert" })
