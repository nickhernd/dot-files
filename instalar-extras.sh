#!/usr/bin/env bash
# Extras: quita Obsidian, instala TeXstudio y herramientas para ingeniería/matemáticas.
set -e

echo ":: Quitando Obsidian"
if pacman -Q obsidian >/dev/null 2>&1; then
  sudo pacman -Rns --noconfirm obsidian
else
  echo "   (ya no estaba)"
fi

echo ":: TeXstudio (+ LaTeX si aún no está)"
yay -S --needed texstudio texlive-basic texlive-latexextra texlive-mathscience texlive-langspanish texlive-fontsrecommended

echo ":: Terminal y flujo de trabajo"
#  atuin: historial de comandos buscable (Ctrl+R)   direnv: variables por proyecto
#  just: tareas por proyecto (justfile)              watchexec: re-ejecutar al guardar
yay -S --needed atuin bash-preexec direnv just watchexec tectonic tree-sitter-cli

echo ":: Estudio e investigación"
#  sioyek: visor de PDF para papers/libros de mates   zotero: gestor de bibliografía
#  anki: tarjetas de repaso                           localsend: pasar archivos al móvil
yay -S --needed sioyek-appimage zotero-bin anki localsend-bin

echo ":: Lean 4 (demostrador de teoremas, con soporte en Neovim)"
yay -S --needed elan-lean
elan default stable || true

echo ""
echo "Listo ✔  Abre una terminal nueva para activar atuin (Ctrl+R) y direnv."
