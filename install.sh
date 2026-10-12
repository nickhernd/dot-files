#!/bin/bash
# install.sh — Enlaza (symlinks) la configuración del repo en el sistema.
# Hace backup (.bak) de lo que ya exista. Lo llama bootstrap.sh; también se puede usar solo.
#
#   ./install.sh                     pregunta el perfil de la máquina la primera vez
#   ./install.sh --perfil sobremesa  fija el perfil: sobremesa | portatil
#   ./install.sh --auto              sin preguntar (portátil si hay batería, si no sobremesa)

set -e

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="$HOME/.config"

echo "==> Enlazando dotfiles desde: $DOTFILES_DIR"

# --- Perfil de la máquina ------------------------------------------------------
# Lo que cambia entre el portátil y el sobremesa (monitores, pantalla principal del
# rice, fondo inicial, tableta) se elige con ~/.config/dotfiles/perfil. Lo leen
# hypr/monitors.lua, quickshell/services/Screens.qml, wallpapers.sh y xppen-monitor.sh.
PERFIL_FILE="$CONFIG_DIR/dotfiles/perfil"
perfil=""; auto=0
while (($#)); do
    case $1 in
        --perfil) perfil=${2:-}; shift ;;
        --perfil=*) perfil=${1#*=} ;;
        --auto) auto=1 ;;
    esac
    shift
done
[[ -z $perfil && -s $PERFIL_FILE ]] && perfil=$(<"$PERFIL_FILE")
if [[ -z $perfil ]]; then
    sugerido=sobremesa; compgen -G "/sys/class/power_supply/BAT*" >/dev/null && sugerido=portatil
    if ((auto)) || [[ ! -t 0 ]]; then
        perfil=$sugerido
    else
        echo "  ¿Qué ordenador es este?"
        echo "    1) sobremesa  (dos monitores: el principal a la derecha, fondo Ascendiente)"
        echo "    2) portatil   (pantalla interna, fondo The Longest Sword)"
        read -rp "  Elige [1/2] (Enter = $sugerido): " r
        case $r in 1|sobremesa) perfil=sobremesa ;; 2|portatil) perfil=portatil ;; *) perfil=$sugerido ;; esac
    fi
fi
case $perfil in
    sobremesa|portatil) ;;
    *) echo "Perfil desconocido: $perfil (usa sobremesa o portatil)" >&2; exit 1 ;;
esac
mkdir -p "$(dirname "$PERFIL_FILE")"
echo "$perfil" > "$PERFIL_FILE"
echo "  [perfil] $perfil"

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
           lazygit lazydocker gh-dash btop yazi micro ranger ripgrep mise imv xournalpp opencode newsboat atuin ZapZap voxtype \
           okular texstudio qalculate wiremix crossnote OpenTabletDriver fontconfig; do
    link "$DOTFILES_DIR/config/$dir" "$CONFIG_DIR/$dir"
done

# Archivos sueltos de ~/.config
for f in aerc/aerc.conf aerc/binds.conf aerc/stylesets starship.toml mimeapps.list omarchy/shell.json rclone/gdrive-filters.txt \
         systemd/user/gdrive-sync.service systemd/user/gdrive-sync.timer systemd/user/gdrive-mount.service \
         systemd/user/tracker-backup.service systemd/user/tracker-backup.timer systemd/user/voxtype.service \
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

# termshark (Wireshark en terminal): tema Moon Pink. Solo se enlazan los temas;
# termshark.toml lo reescribe el propio programa (archivos recientes), así que solo se fijan las claves del tema.
link "$DOTFILES_DIR/config/termshark/themes" "$CONFIG_DIR/termshark/themes"
TS="$CONFIG_DIR/termshark/termshark.toml"
[[ -f $TS ]] || printf '[main]\n' > "$TS"
for kv in 'dark-mode = true' 'colors = false' 'theme-256 = "moon-pink"' 'theme-truecolor = "moon-pink"'; do
    key=${kv%% =*}
    if grep -q "^ *$key *=" "$TS"; then sed -i "s|^ *$key *=.*|  $kv|" "$TS"; else sed -i "/^\[main\]/a\  $kv" "$TS"; fi
done
echo "  [tema] termshark -> moon-pink"

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
# Sin salvapantallas de Omarchy (el bloqueo a los 5 min se mantiene)
touch "$HOME/.local/state/omarchy/toggles/screensaver-off"

# Plantilla de secretos (no está en el repo)
if [[ ! -f $CONFIG_DIR/secrets.env ]]; then
    printf '# API keys y tokens (NO subir a git)\n# export GEMINI_API_KEY="..."\n' > "$CONFIG_DIR/secrets.env"
    chmod 600 "$CONFIG_DIR/secrets.env"
    echo "  [nuevo] $CONFIG_DIR/secrets.env (rellénalo con tus claves)"
fi

echo "==> Enlaces hechos."
