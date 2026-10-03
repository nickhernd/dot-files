#!/bin/bash
# sync.sh — Copia la configuración actual del sistema al repo (sistema -> repo).
# Uso: ./sync.sh   (update.sh lo ejecuta antes de commitear)
# Los secretos (~/.config/secrets.env, rclone.conf, gh/hosts.yml...) NUNCA se copian.

set -e

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
C="$HOME/.config"
R="$DOTFILES_DIR/config"

RSYNC=(rsync -a --delete --exclude '*.bak*' --exclude '*.log' --exclude '__pycache__/')

# Carpetas de ~/.config
DIRS=(
  hypr quickshell matugen rofi cava
  kitty foot ghostty alacritty
  nvim nvim-classic tmux git lazygit lazydocker gh-dash btop yazi micro ranger ripgrep mise
  imv xournalpp opencode okular texstudio qalculate wiremix crossnote OpenTabletDriver fontconfig
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
cp "$C/omarchy/shell.json" "$R/omarchy/"
for d in extensions hooks branding themed plugins themes; do
  [[ -d $C/omarchy/$d ]] && "${RSYNC[@]}" --exclude 'backgrounds/' "$C/omarchy/$d/" "$R/omarchy/$d/"
done

# Archivos sueltos
cp "$C/starship.toml" "$R/"
[[ -f $C/mimeapps.list ]] && cp "$C/mimeapps.list" "$R/"
mkdir -p "$R/rclone" "$R/systemd/user"
[[ -f $C/rclone/gdrive-filters.txt ]] && cp "$C/rclone/gdrive-filters.txt" "$R/rclone/"
cp "$C"/systemd/user/gdrive-sync.{service,timer} "$R/systemd/user/" 2>/dev/null || true

# Home
H="$DOTFILES_DIR/home"
cp ~/.bashrc ~/.bash_profile "$H/"
[[ -f ~/.nanorc ]] && cp ~/.nanorc "$H/"
mkdir -p "$H/.local/bin"
for s in setwall mathpad gdrive-sync dev-status battery-status net-info formula-of-day sec-status news-top hn-top \
         fzf-files fzf-grep git-pull-all git-push-all git-scan rg-pink tabletscreen xppen-monitor.sh; do
  f=~/.local/bin/$s
  [[ -e $f ]] && cp -P "$f" "$H/.local/bin/"
done

# Script de dependencias
for s in instalar-rice.sh instalar-extras.sh instalar-seguridad.sh; do [[ -f ~/$s ]] && cp ~/$s "$DOTFILES_DIR/"; done

# Comprobación de seguridad: que no se cuele ningún secreto
if grep -rIlE 'AIza[0-9A-Za-z_-]{30,}|ghp_[0-9A-Za-z]{30,}|gho_[0-9A-Za-z]{30,}|sk-[0-9A-Za-z]{30,}|"refresh_token"' \
     "$DOTFILES_DIR" --exclude-dir=.git --exclude=sync.sh; then
  echo "!! Posible secreto en los archivos de arriba. Revísalo antes de commitear." >&2
  exit 1
fi

echo "==> Sincronizado sistema -> repo"
