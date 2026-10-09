#!/usr/bin/env bash
# bootstrap.sh — Deja un ordenador nuevo con Omarchy igual que el mío, en un solo paso.
#
#   git clone https://github.com/nickhernd/dot-files.git ~/dot-files
#   ~/dot-files/bootstrap.sh            # pregunta qué bloques instalar
#   ~/dot-files/bootstrap.sh --all      # todo sin preguntar
#
# Bloques:  enlaces (install.sh) · rice + TUIs + mates (instalar-rice.sh)
#           extras de estudio (instalar-extras.sh) · bajo nivel y seguridad (instalar-seguridad.sh)
#           fondos (wallpapers.sh) · fuentes de iconos · tema Moon Pink · plugins de Neovim y yazi

set -e
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$DOTFILES_DIR"

ALL=0
[[ ${1:-} == --all || ${1:-} == -y ]] && ALL=1

# Con --all, yay no pregunta paquete a paquete (la contraseña se pide una vez)
if ((ALL)); then
  yay() { command yay --noconfirm --answerdiff None --answerclean None --removemake "$@"; }
  export -f yay
  sudo -v || exit 1
  ( while true; do sudo -n true; sleep 50; done ) 2>/dev/null &
  KEEP=$!
  trap 'kill $KEEP 2>/dev/null' EXIT
fi

info() { printf '\n\033[1;35m==> %s\033[0m\n' "$*"; }
warn() { printf '\033[1;33m!!  %s\033[0m\n' "$*" >&2; }
ask()  { ((ALL)) && return 0; read -rp "$1 [S/n] " r; [[ ! $r =~ ^[Nn]$ ]]; }

# --- Comprobaciones ---------------------------------------------------------
[[ $EUID -eq 0 ]] && { warn "Ejecútalo como tu usuario, no como root."; exit 1; }
command -v pacman >/dev/null || { warn "Esto es para Arch Linux."; exit 1; }
command -v omarchy >/dev/null || warn "No encuentro Omarchy: instala Omarchy primero (https://omarchy.org)."
command -v yay >/dev/null || { info "Instalando yay"; sudo pacman -S --needed --noconfirm yay || {
  sudo pacman -S --needed --noconfirm git base-devel
  tmp=$(mktemp -d); git clone https://aur.archlinux.org/yay-bin.git "$tmp/yay-bin"
  (cd "$tmp/yay-bin" && makepkg -si --noconfirm); rm -rf "$tmp"; }; }
sudo pacman -S --needed --noconfirm rsync jq imagemagick curl git

# --- 1. Enlaces --------------------------------------------------------------
info "1/7 Enlazando configuración"
./install.sh

# --- 2. Paquetes -------------------------------------------------------------
info "2/7 Paquetes"
ask "¿Rice de Quickshell, TUIs, LaTeX/Typst, Python científico, Docker y Drive?" && ./instalar-rice.sh
ask "¿Extras de estudio (TeXstudio, sioyek, Zotero, Anki, Lean, atuin...)?" && ./instalar-extras.sh
ask "¿Bajo nivel y seguridad (pwndbg, ghidra, wireshark, qemu, lynis...)?" && ./instalar-seguridad.sh
ask "¿TUIs extra (lazyjournal, termshark, newsboat, ytermusic, kalker, visidata...)?" && ./instalar-tuis.sh

# --- 3. Fuentes de iconos ------------------------------------------------------
info "3/7 Fuentes de iconos"
F="$HOME/.local/share/fonts"; mkdir -p "$F"
fc-list | grep -qi "Material Symbols Rounded" || curl -sfL -m 300 -o "$F/MaterialSymbolsRounded.ttf" \
  "https://github.com/google/material-design-icons/raw/master/variablefont/MaterialSymbolsRounded%5BFILL,GRAD,opsz,wght%5D.ttf"
fc-list | grep -qi "Material Design Icons" || curl -sfL -m 120 -o "$F/materialdesignicons-webfont.ttf" \
  "https://cdn.jsdelivr.net/npm/@mdi/font/fonts/materialdesignicons-webfont.ttf"
fc-cache -f >/dev/null

# --- 4. Fondos ---------------------------------------------------------------
info "4/7 Fondos de pantalla"
./wallpapers.sh

# --- 5. Tema -----------------------------------------------------------------
info "5/7 Tema Moon Pink"
command -v omarchy >/dev/null && omarchy theme set moon-pink || warn "No se pudo aplicar el tema"

# --- 6. Plugins --------------------------------------------------------------
info "6/7 Plugins de Neovim y yazi"
command -v ya >/dev/null && ya pkg install >/dev/null 2>&1 || true
command -v nvim >/dev/null && timeout 900 nvim --headless "+Lazy! sync" +qa >/dev/null 2>&1 || true

# --- 7. Servicios y arranque del rice ---------------------------------------
info "7/7 Servicios"
systemctl --user daemon-reload
mkdir -p "$HOME/.local/state/quickshell"
# Fondo inicial: el guardado en el repo
first=$(ls "$DOTFILES_DIR"/wallpapers/*.{jpg,png} 2>/dev/null | head -1)
[[ -n $first && ! -e $HOME/.cache/current_wallpaper ]] && ln -sfn "$HOME/Pictures/wallpapers/$(basename "$first")" "$HOME/.cache/current_wallpaper"
# Tracker de hábitos: restaurar la copia cifrada si está la clave
mkdir -p "$HOME/.local/share/tracker"
if [[ -f $HOME/.config/tracker/backup.key ]]; then
  "$HOME/.local/bin/tracker-backup" || true     # baja y combina los datos del otro ordenador
fi
systemctl --user enable --now tracker-backup.timer 2>/dev/null || true
[[ -f $HOME/todo.md ]] || printf '# Tareas\n\n- [ ] Primera tarea\n' > "$HOME/todo.md"
if pgrep -x Hyprland >/dev/null; then
  hyprctl reload >/dev/null 2>&1 || true
  pkill -x qs || true; (uwsm-app -- qs >/dev/null 2>&1 &)
fi

cat <<'MSG'

==> ¡Listo! Pasos manuales:
  1. Rellena ~/.config/secrets.env con tus API keys.
  2. gh auth login  &&  gh extension install dlvhdr/gh-dash
  3. Google Drive: rclone config create gdrive drive scope=drive
     systemctl --user enable --now gdrive-mount.service   (monta Drive en ~/GoogleDrive)
  4. Cierra sesión y vuelve a entrar (grupos docker, wireshark y libvirt).
  5. Tracker: copia la MISMA clave a ~/.config/tracker/backup.key y ejecuta: tracker sync
  6. Abre nvim una vez para que Mason termine de instalar los servidores de lenguaje.
MSG
