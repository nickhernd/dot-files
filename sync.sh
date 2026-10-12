#!/bin/bash
# sync.sh — Copia la configuración actual del sistema al repo (sistema -> repo).
# Uso: ./sync.sh   (update.sh lo ejecuta antes de commitear)
# Los secretos (~/.config/secrets.env, rclone.conf, gh/hosts.yml...) NUNCA se copian.

set -e

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
C="$HOME/.config"
R="$DOTFILES_DIR/config"

RSYNC=(rsync -a --delete --exclude '*.bak*' --exclude '*.log' --exclude '__pycache__/')

# copiar [-P] origen... destino/ — copia lo que exista y salta lo que ya es el mismo
# archivo (lo enlazado por install.sh apunta al repo y cp fallaría con "same file").
copiar() {
  local opt=(); [[ $1 == -P ]] && { opt=(-P); shift; }
  local dest=${*: -1} f
  for f in "${@:1:$#-1}"; do
    [[ -e $f || -L $f ]] || continue
    [[ $f -ef $dest/$(basename "$f") ]] && continue
    cp "${opt[@]}" "$f" "$dest/"
  done
}

# Carpetas de ~/.config
DIRS=(
  hypr quickshell matugen rofi cava scripts
  kitty foot ghostty alacritty
  nvim nvim-classic tmux git lazygit lazydocker gh-dash btop yazi micro ranger ripgrep mise
  newsboat atuin ZapZap voxtype imv xournalpp opencode okular texstudio qalculate wiremix crossnote OpenTabletDriver fontconfig
)
for d in "${DIRS[@]}"; do
  [[ -d $C/$d ]] || continue
  mkdir -p "$R/$d"
  "${RSYNC[@]}" \
    --exclude 'micro/backups/' --exclude 'micro/buffers/' \
    --exclude 'lua/plugins/theme.lua' \
    "$C/$d/" "$R/$d/"
done

# Omarchy: solo lo que es configuración del usuario (no el tema actual)
mkdir -p "$R/omarchy"
copiar "$C/omarchy/shell.json" "$R/omarchy"
for d in extensions hooks branding themed plugins themes; do
  # --copy-links: los archivos del tema son enlaces al repo; sin él se copiaría el
  # enlace encima del archivo de verdad y quedaría apuntándose a sí mismo
  [[ -d $C/omarchy/$d ]] && "${RSYNC[@]}" --copy-links --exclude 'backgrounds/' "$C/omarchy/$d/" "$R/omarchy/$d/"
done

# termshark: solo los temas (termshark.toml guarda archivos recientes)
[[ -d $C/termshark/themes ]] && mkdir -p "$R/termshark/themes" && "${RSYNC[@]}" "$C/termshark/themes/" "$R/termshark/themes/"

# Archivos sueltos
copiar "$C/starship.toml" "$C/mimeapps.list" "$C/okularrc" "$C/okularpartrc" "$C/xdg-terminals.list" "$R"
# aerc: configuración y atajos (accounts.conf NO: lleva la cuenta de correo)
mkdir -p "$R/aerc"
copiar "$C/aerc/aerc.conf" "$C/aerc/binds.conf" "$R/aerc"
mkdir -p "$R/rclone" "$R/systemd/user"
copiar "$C/rclone/gdrive-filters.txt" "$R/rclone"
copiar "$C"/systemd/user/{gdrive-sync.service,gdrive-sync.timer,gdrive-mount.service,tracker-backup.service,tracker-backup.timer,voxtype.service} "$R/systemd/user"

# Fondo de pantalla actual (el que está puesto) -> wallpapers/
mkdir -p "$DOTFILES_DIR/wallpapers"
cur=$(readlink -f "$HOME/.cache/current_wallpaper" 2>/dev/null)
[[ -f $cur ]] && copiar "$cur" "$DOTFILES_DIR/wallpapers"

# Home
H="$DOTFILES_DIR/home"
copiar ~/.bashrc ~/.bash_profile ~/.nanorc "$H"
mkdir -p "$H/.local/bin"
for s in mathpad gdrive-sync gdrive-setup dev-status battery-status net-info formula-of-day sec-status news-top palabra-del-dia gh-contrib tlc bgb webodm cpp-new perf-flame asm-diff hn-top maint-status maint-clean tracker tracker-backup tracker-xlsx \
         fzf-files fzf-grep git-pull-all git-push-all git-scan rg-pink tabletscreen xppen-monitor.sh; do
  copiar -P ~/.local/bin/$s "$H/.local/bin"
done

# Comprobación de seguridad: que no se cuele ningún secreto
if grep -rIlE 'AIza[0-9A-Za-z_-]{30,}|ghp_[0-9A-Za-z]{30,}|gho_[0-9A-Za-z]{30,}|sk-[0-9A-Za-z]{30,}|"refresh_token"' \
     "$DOTFILES_DIR" --exclude-dir=.git --exclude=sync.sh; then
  echo "!! Posible secreto en los archivos de arriba. Revísalo antes de commitear." >&2
  exit 1
fi

echo "==> Sincronizado sistema -> repo"
