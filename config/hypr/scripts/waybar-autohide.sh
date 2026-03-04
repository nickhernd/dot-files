#!/bin/bash
# Daemon de auto-ocultación para Waybar
# Muestra la barra cuando el cursor está en el borde superior,
# la oculta tras 2 segundos si el cursor se aleja.
# Waybar gestiona el exclusive zone automáticamente al ocultarse/mostrarse.

SHOW_THRESHOLD=5   # px desde el borde superior para activar la barra
HIDE_DELAY=2       # segundos antes de ocultar

bar_visible=true
last_top_time=$(date +%s)

while true; do
    sleep 0.15

    y=$(hyprctl cursorpos -j 2>/dev/null | jq -r '.y' 2>/dev/null)
    [[ -z "$y" || "$y" == "null" ]] && continue

    now=$(date +%s)

    if (( y <= SHOW_THRESHOLD )); then
        last_top_time=$now
        if [[ "$bar_visible" == "false" ]]; then
            killall -SIGUSR1 waybar 2>/dev/null
            bar_visible=true
        fi
    elif [[ "$bar_visible" == "true" ]]; then
        elapsed=$(( now - last_top_time ))
        if (( elapsed >= HIDE_DELAY )); then
            killall -SIGUSR1 waybar 2>/dev/null
            bar_visible=false
        fi
    fi
done
