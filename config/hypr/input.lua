-- Personal input overrides (portado de dot-files/config/hypr/input.conf)
hl.config({
  input = {
    kb_layout = "es",
    kb_options = "compose:caps",
    repeat_rate = 40,
    repeat_delay = 600,
    numlock_by_default = true,

    tablet = {
      output = "eDP-1",
    },

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
