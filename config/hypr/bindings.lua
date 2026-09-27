-- Personal keybinding overrides. See current bindings:
--   omarchy menu keybindings --print

-------------------------------------------------------------
-- Rice Quickshell (dhrruvsharma/shell) — paneles vía IPC
-------------------------------------------------------------
local function qs(target, fn)
  return "qs ipc call " .. target .. " " .. (fn or "toggle")
end

o.bind("SUPER + ALT + C", "Centro de control", qs("controlCenter", "changeVisible"))
o.bind("SUPER + ALT + N", "Panel de red/bluetooth", qs("networkPanel", "changeVisible"))
o.bind("SUPER + ALT + W", "Selector de wallpaper", qs("wallpaper"))
o.bind("SUPER + ALT + H", "Wallhaven (descargar wallpapers)", qs("wallhavenPanel"))
o.bind("SUPER + ALT + P", "Menú de apagado", qs("powerMenu"))
o.bind("SUPER + ALT + A", "Panel multimedia", qs("mediaPanel"))
o.bind("SUPER + ALT + D", "Calendario", qs("calendarWindow"))
o.bind("SUPER + ALT + E", "Vista de ventanas (expose)", qs("expose"))
o.bind("SUPER + ALT + U", "Actualizaciones", qs("updatesPanel"))
o.bind("SUPER + ALT + R", "Lanzador del rice", qs("launcherWindow"))
o.bind("SUPER + ALT + T", "Notas", qs("notepad"))

-------------------------------------------------------------
-- De dot-files
-------------------------------------------------------------
hl.unbind("SUPER + SHIFT + S")
o.bind("SUPER + SHIFT + S", "Captura de pantalla", "omarchy-capture-screenshot")
o.bind("SUPER + SHIFT + R", "Grabar pantalla (toggle)", "omarchy-capture-screenrecording")

-- Redimensionar ventana con CTRL + flechas
o.bind("CTRL + left", "Reducir ancho", hl.dsp.window.resize({ x = -40, y = 0, relative = true }), { repeating = true })
o.bind("CTRL + right", "Aumentar ancho", hl.dsp.window.resize({ x = 40, y = 0, relative = true }), { repeating = true })
o.bind("CTRL + up", "Reducir alto", hl.dsp.window.resize({ x = 0, y = -40, relative = true }), { repeating = true })
o.bind("CTRL + down", "Aumentar alto", hl.dsp.window.resize({ x = 0, y = 40, relative = true }), { repeating = true })

-- Modo ratón con teclado (requiere ydotool). SUPER+ALT+M entra, ESC sale.
local ydo = "YDOTOOL_SOCKET=/run/user/1000/.ydotool_socket ydotool "
local function mv(x, y) return ydo .. "mousemove -- " .. x .. " " .. y end

o.bind("SUPER + ALT + M", "Activar control de ratón con teclado", function()
  hl.dispatch(hl.dsp.exec_cmd('notify-send -t 2000 "Mouse Mode" "Activado — Flechas/HJKL=mover, Enter=click, ESC=salir"'))
  hl.dispatch(hl.dsp.submap("mousemode"))
end)

hl.define_submap("mousemode", function()
  local r = { repeating = true }
  for _, k in ipairs({ { "left", "h", -1, 0 }, { "right", "l", 1, 0 }, { "up", "k", 0, -1 }, { "down", "j", 0, 1 } }) do
    hl.bind(k[1], hl.dsp.exec_cmd(mv(k[3] * 20, k[4] * 20)), r)
    hl.bind(k[2], hl.dsp.exec_cmd(mv(k[3] * 20, k[4] * 20)), r)
    hl.bind("SHIFT + " .. k[1], hl.dsp.exec_cmd(mv(k[3] * 100, k[4] * 100)), r)
    hl.bind("SHIFT + " .. k[2], hl.dsp.exec_cmd(mv(k[3] * 100, k[4] * 100)), r)
  end
  hl.bind("Return", hl.dsp.exec_cmd(ydo .. "click 0xC0"))        -- izquierdo
  hl.bind("SHIFT + Return", hl.dsp.exec_cmd(ydo .. "click 0xC1")) -- derecho
  hl.bind("space", hl.dsp.exec_cmd(ydo .. "click 0xC2"))         -- medio
  hl.bind("Prior", hl.dsp.exec_cmd(ydo .. "click 0xC5"), r)      -- scroll arriba
  hl.bind("Next", hl.dsp.exec_cmd(ydo .. "click 0xC6"), r)       -- scroll abajo

  local function leave()
    hl.dispatch(hl.dsp.exec_cmd('notify-send -t 1500 "Mouse Mode" "Desactivado"'))
    hl.dispatch(hl.dsp.submap("reset"))
  end
  hl.bind("Escape", leave)
  hl.bind("SUPER + ALT + M", leave)
end)

-------------------------------------------------------------
-- Entorno de trabajo: TUIs y herramientas
-------------------------------------------------------------
o.bind("SUPER + SHIFT + I", "GitHub issues/PRs (gh-dash)", "omarchy-launch-tui gh dash")
o.bind("SUPER + SHIFT + U", "Gestor de archivos (yazi)", "omarchy-launch-tui yazi")
o.bind("SUPER + SHIFT + Q", "Calculadora (qalc)", "omarchy-launch-tui qalc")
o.bind("SUPER + SHIFT + J", "Consola matemática (SymPy)", "omarchy-launch-tui mathpad")
o.bind("SUPER + SHIFT + K", "Disco (gdu)", "omarchy-launch-tui gdu")

-- Calculadora y consola matemática flotan centradas
o.window({ class = "org.omarchy.qalc" }, { float = true, center = true, size = { 720, 480 } })
o.window({ class = "org.omarchy.mathpad" }, { float = true, center = true, size = { 1100, 700 } })
o.bind("SUPER + ALT + O", "Pomodoro: iniciar/pausar", "qs ipc call pomodoro toggle")
