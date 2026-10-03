#!/usr/bin/env bash
# Instala dependencias del rice + entorno de trabajo (ingeniería informática / matemáticas).
set -e

echo ":: Rice (Quickshell)"
yay -S --needed \
  playerctl cliphist wf-recorder cava rofi ydotool \
  ttf-iosevka-nerd ttf-nerd-fonts-symbols ttf-material-symbols-variable-git \
  noto-fonts-cjk

echo ":: TUIs y utilidades de terminal"
yay -S --needed \
  yazi micro w3m glow git-delta dust duf gdu go-yq xh hyperfine tokei \
  libqalculate lazysql posting

git config --global core.pager delta
git config --global interactive.diffFilter "delta --color-only"

echo ":: Google Drive"
yay -S --needed rclone

echo ":: Desarrollo"
yay -S --needed valgrind cmake uv

echo ":: Matemáticas y documentos"
yay -S --needed typst pandoc-cli gnuplot octave maxima zathura zathura-pdf-mupdf \
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
pkill -x qs || true
(setsid qs >/dev/null 2>&1 &)

cat <<'MSG'

Listo ✔  Pasos manuales que faltan:
  1. gh auth login                         (inicia sesión en GitHub)
  2. gh extension install dlvhdr/gh-dash   (TUI de issues/PRs: SUPER+SHIFT+I o 'gd')
  3. gdrive-sync --setup                   (abre el navegador para autorizar Google Drive)
     systemctl --user enable --now gdrive-sync.timer   (sincroniza sola cada 15 min)
  4. Cierra sesión y vuelve a entrar para que el grupo docker tenga efecto.
MSG
