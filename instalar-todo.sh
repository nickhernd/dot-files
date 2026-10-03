#!/usr/bin/env bash
# Ejecuta todos los instaladores pendientes sin pedir confirmación paquete a paquete.
yay() { command yay --noconfirm --answerdiff None --answerclean None --removemake "$@"; }
export -f yay

echo "Introduce tu contraseña una vez (se mantiene durante la instalación):"
sudo -v || exit 1
( while true; do sudo -n true; sleep 50; done ) 2>/dev/null & KEEP=$!
trap 'kill $KEEP 2>/dev/null' EXIT

ok=(); fail=()
for s in instalar-rice.sh instalar-seguridad.sh instalar-tuis.sh; do
  printf '\n\033[1;35m################ %s ################\033[0m\n' "$s"
  if bash "$HOME/$s"; then ok+=("$s"); else fail+=("$s"); fi
done

printf '\n\033[1;35m==> Resumen\033[0m\n'
for s in "${ok[@]}"; do echo "  ✔ $s"; done
for s in "${fail[@]}"; do echo "  ✘ $s (revisa los mensajes de arriba)"; done
