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
for dir in hypr waybar nvim kitty alacritty ghostty walker mako btop fastfetch ranger lazygit git; do
    link_config "$dir"
done

# Config files
link_config "starship.toml"

# Home dotfiles
for f in .bashrc .bash_profile .bash_logout .nanorc .gitignore; do
    link_home "$f"
done

echo ""
echo "==> Hecho. Reinicia la sesión o ejecuta 'source ~/.bashrc' para aplicar los cambios."
