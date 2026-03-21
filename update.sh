#!/bin/bash
# update.sh — Actualiza el repositorio de dotfiles
# Uso: ./update.sh
# Detecta cambios, hace commit y opcionalmente push.
# (Los configs ya están enlazados via symlinks, no hace falta copiar nada)

set -e

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$DOTFILES_DIR"

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
RESET='\033[0m'

echo -e "${CYAN}==> Dotfiles:${RESET} $DOTFILES_DIR"
echo ""

# Mostrar estado
echo -e "${CYAN}==> Estado actual:${RESET}"
git status --short

if ! git status --porcelain | grep -q .; then
  echo -e "${GREEN}  Sin cambios. Todo está al día.${RESET}"
  exit 0
fi

echo ""
git add -A

echo -e "${CYAN}==> Cambios a commitear:${RESET}"
git diff --cached --stat
echo ""

read -rp "Mensaje del commit [update dotfiles]: " msg
msg="${msg:-update dotfiles}"

git commit -m "$msg"
echo -e "${GREEN}  ✓ Commit creado${RESET}"

echo ""
read -rp "¿Push al remoto? [y/N]: " push
if [[ "$push" =~ ^[Yy]$ ]]; then
  git push
  echo -e "${GREEN}  ✓ Push completado${RESET}"
fi

echo ""
echo -e "${GREEN}==> ¡Listo!${RESET}"
