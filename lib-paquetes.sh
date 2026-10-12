# lib-paquetes.sh — lo cargan los instalar-*.sh.
# `instalar paq...` instala con yay sin abortar si un paquete falla: primero en
# bloque y, si algo va mal, uno a uno. Los que no se instalan van a FALLIDOS y
# `resumen` los lista al final (sale con error si hay alguno).

FALLIDOS=()

# Paquetes que se saltan según el perfil de la máquina (~/.config/dotfiles/perfil).
# En el portátil nada de LLVM: include-what-you-use obliga a compilar LLVM/Clang entero.
PERFIL_MAQUINA=$(cat "$HOME/.config/dotfiles/perfil" 2>/dev/null)
case $PERFIL_MAQUINA in
  portatil) SALTAR=(include-what-you-use clang-static-git lldb clang) ;;
  *)        SALTAR=() ;;
esac

instalar() {
  local keep=() x s
  for x in "$@"; do
    for s in "${SALTAR[@]}"; do [[ $x == "$s" ]] && continue 2; done
    keep+=("$x")
  done
  set -- "${keep[@]}"
  (($#)) || return 0
  yay -S --needed "$@" && return 0
  local p
  for p in "$@"; do
    pacman -Q "$p" &>/dev/null || yay -S --needed "$p" || FALLIDOS+=("$p")
  done
  return 0
}

resumen() {
  if ((${#FALLIDOS[@]})); then
    printf '\033[1;33m!!  No se pudieron instalar: %s\033[0m\n' "${FALLIDOS[*]}" >&2
    printf '    Vuelve a ejecutar este script cuando lo arregles (los ya instalados se saltan).\n' >&2
    return 1
  fi
}
