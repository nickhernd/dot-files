-- Sobremesa: dos monitores. El principal (Samsung, el de enfrente) a la derecha,
-- solo con el fondo, y el AOC a la izquierda con toda la información del rice:
-- barra, reloj, widgets, tracker y paneles (quickshell/services/Screens.qml).
hl.monitor({ output = "DP-4", mode = "1920x1080@60", position = "0x0", scale = 1 })        -- AOC 2343, rice
hl.monitor({ output = "HDMI-A-1", mode = "1920x1080@75", position = "1920x0", scale = 1 }) -- Samsung S27C31x, principal

hl.config({
  input = {
    tablet = {
      output = "HDMI-A-1",
    },
  },
})
