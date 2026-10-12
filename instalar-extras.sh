#!/usr/bin/env bash
# Extras: quita Obsidian, instala TeXstudio y herramientas para ingeniería/matemáticas.
source "$(dirname "${BASH_SOURCE[0]}")/lib-paquetes.sh"

echo ":: Quitando Obsidian"
if pacman -Q obsidian >/dev/null 2>&1; then
  sudo pacman -Rns --noconfirm obsidian
else
  echo "   (ya no estaba)"
fi

echo ":: TeXstudio (+ LaTeX si aún no está)"
instalar texstudio texlive-basic texlive-latexextra texlive-mathscience texlive-langspanish texlive-fontsrecommended

echo ":: Terminal y flujo de trabajo"
#  atuin: historial de comandos buscable (Ctrl+R)   direnv: variables por proyecto
#  just: tareas por proyecto (justfile)              watchexec: re-ejecutar al guardar
instalar atuin bash-preexec direnv just watchexec tectonic tree-sitter-cli

echo ":: Mensajería"
#  zapzap: WhatsApp con icono en la bandeja (como Telegram)
instalar zapzap

echo ":: Estudio e investigación"
#  sioyek: visor de PDF para papers/libros de mates   zotero: gestor de bibliografía
#  anki: tarjetas de repaso                           localsend: pasar archivos al móvil
<<<<<<< HEAD
instalar sioyek-appimage zotero-bin anki localsend
||||||| parent of 7922153 (yazi: abrir PDFs con Zathura primero (Okular no estaba instalado y fallaba sin avisar))
instalar sioyek-appimage zotero-bin anki localsend-bin
=======
#  okular: PDFs con anotaciones (su config está en el repo)
instalar sioyek-appimage zotero-bin anki localsend-bin okular
>>>>>>> 7922153 (yazi: abrir PDFs con Zathura primero (Okular no estaba instalado y fallaba sin avisar))

echo ":: Lean 4 (demostrador de teoremas, con soporte en Neovim)"
instalar elan-lean
elan default stable || true

echo ""
echo "Listo ✔  Abre una terminal nueva para activar atuin (Ctrl+R) y direnv."

resumen
