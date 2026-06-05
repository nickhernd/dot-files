#!/bin/bash
# Toggle between single monitor (Samsung only) and dual monitor

ESTADO_FILE="/tmp/monitor-dual-activo"

if [ -f "$ESTADO_FILE" ]; then
    # Volver a dual: activar AOC
    hyprctl keyword monitor "DP-4,1920x1080@60,0x0,1"
    rm "$ESTADO_FILE"
    notify-send "Monitores" "Modo dual activado" --expire-time=2000
else
    # Pasar a single: desactivar AOC, mover workspaces al Samsung
    hyprctl dispatch focusmonitor HDMI-A-1
    hyprctl keyword monitor "DP-4,disable"
    touch "$ESTADO_FILE"
    notify-send "Monitores" "Modo una pantalla (Samsung)" --expire-time=2000
fi
