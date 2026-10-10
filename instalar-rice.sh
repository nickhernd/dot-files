#!/usr/bin/env bash
# Instala dependencias del rice + entorno de trabajo (ingeniería informática / matemáticas).
source "$(dirname "${BASH_SOURCE[0]}")/lib-paquetes.sh"

echo ":: Rice (Quickshell)"
instalar \
  playerctl cliphist wf-recorder cava rofi ydotool \
  ttf-iosevka-nerd ttf-nerd-fonts-symbols ttf-material-symbols-variable-git \
  noto-fonts-cjk

echo ":: TUIs y utilidades de terminal"
instalar \
  yazi micro w3m glow git-delta dust duf gdu go-yq xh hyperfine tokei \
  libqalculate lazysql posting

git config --global core.pager delta
git config --global interactive.diffFilter "delta --color-only"

echo ":: Google Drive"
instalar rclone fuse3

echo ":: Desarrollo"
instalar valgrind cmake uv

echo ":: Matemáticas y documentos"
instalar typst pandoc-cli gnuplot octave maxima zathura zathura-pdf-mupdf \
  texlive-basic texlive-latexextra texlive-mathscience texlive-langspanish

xdg-mime default org.pwmt.zathura.desktop application/pdf

# Python científico aislado (no toca el Python del sistema)
uv tool install --upgrade ipython --with sympy,numpy,scipy,matplotlib,pandas
uv tool install --upgrade jupyterlab --with sympy,numpy,scipy,matplotlib,pandas

echo ":: Kitty como terminal por defecto"
omarchy-install-terminal kitty

echo ":: Docker (servicio + tu usuario en el grupo docker)"
sudo systemctl enable --now docker.service
sudo usermod -aG docker "$USER"

echo ":: ydotool (modo ratón SUPER+ALT+M)"
systemctl --user enable --now ydotool.service || true

# Colores: tema fijo Moon Pink (sin matugen, para que el fondo no los cambie).
# Si algún día quieres colores automáticos según el fondo: yay -S matugen

pgrep -f "wl-paste --watch cliphist" >/dev/null || (setsid wl-paste --watch cliphist store >/dev/null 2>&1 &)
pkill -f "^(/usr/bin/)?(qs|quickshell)$" || true   # el rice (no la shell de Omarchy, que lleva argumentos)
(uwsm-app -- qs >/dev/null 2>&1 &)

cat <<'MSG'

Listo ✔  Pasos manuales que faltan:
  1. gh auth login                         (inicia sesión en GitHub)
  2. gh extension install dlvhdr/gh-dash   (TUI de issues/PRs: SUPER+SHIFT+I o 'gd')
  3. gdrive-setup                          (autoriza Google Drive en el navegador y lo monta en ~/GoogleDrive)
  4. Cierra sesión y vuelve a entrar para que el grupo docker tenga efecto.
MSG

resumen
