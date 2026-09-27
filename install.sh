#!/bin/bash
# Script de instalación de dotfiles
# Crea symlinks desde el repo hacia las ubicaciones correctas en el sistema.
# Uso: ./install.sh

set -e

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="$HOME/.config"

echo "==> Instalando dotfiles desde: $DOTFILES_DIR"

backup() {
    local target="$1"
    if [[ -e "$target" && ! -L "$target" ]]; then
        echo "  [backup] $target -> $target.bak"
        mv "$target" "$target.bak"
    fi
}

link_config() {
    local src="$DOTFILES_DIR/config/$1"
    local dst="$CONFIG_DIR/$1"
    [[ -e "$src" ]] || return
    backup "$dst"
    mkdir -p "$(dirname "$dst")"
    ln -sfn "$src" "$dst"
    echo "  [link] $dst"
}

link_home() {
    local src="$DOTFILES_DIR/home/$1"
    local dst="$HOME/$1"
    [[ -e "$src" ]] || return
    backup "$dst"
    ln -sfn "$src" "$dst"
    echo "  [link] $dst"
}

# Config dirs
for dir in hypr quickshell matugen rofi cava kitty foot ghostty alacritty nvim nvim-classic tmux git \
           lazygit lazydocker gh-dash btop yazi micro ranger ripgrep mise imv xournalpp opencode; do
    link_config "$dir"
done

# Config files
for f in starship.toml mimeapps.list omarchy/shell.json rclone/gdrive-filters.txt \
         systemd/user/gdrive-sync.service systemd/user/gdrive-sync.timer; do
    link_config "$f"
done

# Oculta la barra de Omarchy (la sustituye la del rice de Quickshell)
mkdir -p "$HOME/.local/state/omarchy/toggles" && touch "$HOME/.local/state/omarchy/toggles/bar-off"
mkdir -p "$HOME/.local/bin" && ln -sfn "$HOME/.config/quickshell/scripts/setwall" "$HOME/.local/bin/setwall"

# Home dotfiles
# Enlaza todos los archivos y carpetas (incluyendo ocultos) de la carpeta home/ del repo
find "$DOTFILES_DIR/home" -mindepth 1 -maxdepth 1 | while read src; do
    name=$(basename "$src")
    link_home "$name"
done

echo ""
echo "==> Hecho. Instala las dependencias con ./instalar-rice.sh y reinicia la sesión."
echo "    Recuerda crear ~/.config/secrets.env con tus API keys (no está en el repo)."
