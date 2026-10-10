-- Personal input overrides (portado de dot-files/config/hypr/input.conf)
hl.config({
  input = {
    kb_layout = "es",
    -- Bloq Mayús normal (Omarchy lo usa como tecla Compose: no se quedaba fijo y
    -- salía un puntito). Compose pasa a la tecla Menú.
    kb_options = "compose:menu",
    repeat_rate = 40,
    repeat_delay = 600,
    numlock_by_default = true,

    touchpad = {
      scroll_factor = 0.4,
    },
  },
})

-- App-specific touchpad scroll speeds.
o.window("(Alacritty|kitty|foot)", { scroll_touchpad = 1.5 })
o.window("com.mitchellh.ghostty", { scroll_touchpad = 0.2 })

-- Gestos de 3 dedos para cambiar de workspace (del rice)
hl.gesture({ fingers = 3, direction = "horizontal", action = "workspace" })
