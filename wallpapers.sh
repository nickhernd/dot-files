#!/usr/bin/env bash
# wallpapers.sh — Descarga los fondos (wallpapers.txt, de wallhaven.cc) y genera los
# fondos del tema Moon Pink, incluida la versión Moon Pink de "The Longest Sword"
# (Malaz: el Libro de los Caídos, arte de Ina Wong · artofinca.com). Las imágenes no
# se guardan en el repo: se descargan aquí.
set -e
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
W="$HOME/Pictures/wallpapers"
T="$HOME/.config/omarchy/themes/moon-pink/backgrounds"
mkdir -p "$W/malazan" "$T"

echo "==> Descargando fondos"
while read -r url; do
  [[ -z $url || $url == \#* ]] && continue
  f=$(basename "$url")
  dest="$W/$f"; [[ $f == wallhaven-r2811j.jpg ]] && dest="$W/malazan/$f"
  [[ -s $dest ]] || curl -sfL -m 120 -o "$dest" "$url" || echo "   (falló $f)"
done < "$DOTFILES_DIR/wallpapers.txt"

echo "==> Fondos guardados en el repo"
cp -u "$DOTFILES_DIR"/wallpapers/*.{jpg,png} "$W/" 2>/dev/null || true

echo "==> Generando Malaz en Moon Pink (si no está ya)"
src="$W/malazan/wallhaven-r2811j.jpg"
out="$W/malaz-longest-sword-moonpink.jpg"
if [[ -s $src && ! -s $out ]] && command -v magick >/dev/null; then
  clut=$(mktemp --suffix .png)
  magick -size 1x86 gradient:"#0d0a14"-"#3a1f45" -size 1x85 gradient:"#3a1f45"-"#b0508a" \
         -size 1x85 gradient:"#b0508a"-"#ffd0ea" -append -rotate -90 "$clut"
  magick "$src" -colorspace gray -level 3%,97% "$clut" -clut -resize 1920x1080^ \
         -gravity center -extent 1920x1080 -quality 92 "$out"
  rm -f "$clut"
fi

echo "==> Fondos del tema Moon Pink"
cp -n "$out" "$T/0-malaz-longest-sword.jpg" 2>/dev/null || true
[[ -f $W/malaz-ascendiente-moonpink.jpg ]] && cp -n "$W/malaz-ascendiente-moonpink.jpg" "$T/0-malaz-ascendiente.jpg"
for pair in mlg7qm.png:1-topografia.png 7j9wle.png:2-curvas.png 6lykzx.png:3-galaxia.png polllj.jpg:4-planeta.jpg; do
  s="$W/wallhaven-${pair%%:*}"; [[ -s $s ]] && cp -n "$s" "$T/${pair##*:}"
done

# Fondo inicial del rice
[[ -e $HOME/.cache/current_wallpaper ]] || { mkdir -p "$HOME/.cache"; ln -sfn "$out" "$HOME/.cache/current_wallpaper"; }
echo "==> Fondos listos en $W"
