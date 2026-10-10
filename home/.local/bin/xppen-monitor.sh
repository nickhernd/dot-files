#!/bin/bash
# Aplica el área correcta de OTD y la reaplica al reconectar la tablet USB.
# Se lanza desde Hyprland autostart.

# Centro de la pantalla en el escritorio virtual: en el sobremesa (perfil de
# install.sh) la tableta va al Samsung, que está a la derecha del AOC (x 1920-3840).
cx=960
[[ $(cat "$HOME/.config/dotfiles/perfil" 2>/dev/null) == sobremesa ]] && cx=2880

apply_area() {
    sleep 2
    for tablet in "XP-Pen Deco L" "XP-Pen Deco LW"; do
        otd setdisplayarea "$tablet" 1920 1080 $cx 540 2>/dev/null
        otd settabletarea  "$tablet" 254 142.875 127 76.2 0 2>/dev/null
    done
}

# Aplicar al arranque de la sesión (OTD puede tardar en estar listo)
apply_area &

# Monitorear eventos USB: reaplica cuando aparece la XP-Pen (VID 28BD, PID 0935)
udevadm monitor --udev --subsystem-match=usb --property 2>/dev/null | \
    awk '
        /^ACTION=add/            { is_add=1 }
        /^PRODUCT=28bd\/935\//   { if (is_add) { print "reconnect"; fflush() } }
        /^$/                     { is_add=0 }
    ' | \
    while IFS= read -r _; do
        apply_area &
    done
