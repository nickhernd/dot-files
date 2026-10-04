-- Quickshell del rice (barra, centro de control, wallpaper, notificaciones...)
o.exec_on_start("qs")
-- Historial de portapapeles para el clipboard manager del rice
o.launch_on_start("wl-paste --watch cliphist store")

-- Tableta XP-Pen (de dot-files)
o.exec_on_start("[ -x ~/.local/bin/xppen-monitor.sh ] && ~/.local/bin/xppen-monitor.sh")

-- WhatsApp (ZapZap) en la bandeja, como Telegram
o.launch_on_start("zapzap")
