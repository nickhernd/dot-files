#!/bin/bash
# install.sh — Enlaza (symlinks) la configuración del repo en el sistema.
# Hace backup (.bak) de lo que ya exista. Lo llama bootstrap.sh; también se puede usar solo.

set -e

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="$HOME/.config"

echo "==> Enlazando dotfiles desde: $DOTFILES_DIR"

backup() {
    local target="$1"
    if [[ -e "$target" && ! -L "$target" ]]; then
        echo "  [backup] $target -> $target.bak"
        mv "$target" "$target.bak"
    fi
}

link() {
    local src="$1" dst="$2"
    [[ -e "$src" ]] || return 0
    backup "$dst"
    mkdir -p "$(dirname "$dst")"
    ln -sfn "$src" "$dst"
    echo "  [link] $dst"
}

# Carpetas de ~/.config
for dir in hypr quickshell matugen rofi cava scripts kitty foot ghostty alacritty nvim nvim-classic tmux git \
           lazygit lazydocker gh-dash btop yazi micro ranger ripgrep mise imv xournalpp opencode newsboat atuin ZapZap \
           okular texstudio qalculate wiremix crossnote OpenTabletDriver fontconfig; do
    link "$DOTFILES_DIR/config/$dir" "$CONFIG_DIR/$dir"
done

# Archivos sueltos de ~/.config
for f in starship.toml mimeapps.list omarchy/shell.json rclone/gdrive-filters.txt \
         systemd/user/gdrive-sync.service systemd/user/gdrive-sync.timer systemd/user/gdrive-mount.service \
         systemd/user/tracker-backup.service systemd/user/tracker-backup.timer \
         okularrc okularpartrc xdg-terminals.list; do
    link "$DOTFILES_DIR/config/$f" "$CONFIG_DIR/$f"
done

# Tema Moon Pink de Omarchy (los fondos los genera bootstrap.sh)
for t in "$DOTFILES_DIR"/config/omarchy/themes/*/; do
    [[ -d $t ]] || continue
    name=$(basename "$t")
    mkdir -p "$CONFIG_DIR/omarchy/themes/$name"
    for f in "$t"*; do link "$f" "$CONFIG_DIR/omarchy/themes/$name/$(basename "$f")"; done
done

# Dotfiles de $HOME (solo archivos, nunca carpetas enteras como ~/.local)
for f in .bashrc .bash_profile .bash_logout .nanorc; do
    link "$DOTFILES_DIR/home/$f" "$HOME/$f"
done

# Scripts de ~/.local/bin, uno a uno
mkdir -p "$HOME/.local/bin"
for f in "$DOTFILES_DIR"/home/.local/bin/*; do
    [[ -e $f || -L $f ]] || continue
    name=$(basename "$f")
    [[ $name == setwall ]] && continue
    link "$f" "$HOME/.local/bin/$name"
done
ln -sfn "$CONFIG_DIR/quickshell/scripts/setwall" "$HOME/.local/bin/setwall"

# Oculta la barra de Omarchy (la sustituye la del rice de Quickshell)
mkdir -p "$HOME/.local/state/omarchy/toggles" && touch "$HOME/.local/state/omarchy/toggles/bar-off"

# Plantilla de secretos (no está en el repo)
if [[ ! -f $CONFIG_DIR/secrets.env ]]; then
    printf '# API keys y tokens (NO subir a git)\n# export GEMINI_API_KEY="..."\n' > "$CONFIG_DIR/secrets.env"
    chmod 600 "$CONFIG_DIR/secrets.env"
    echo "  [nuevo] $CONFIG_DIR/secrets.env (rellénalo con tus claves)"
fi

echo "==> Enlaces hechos."
