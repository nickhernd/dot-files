# dot-files

Dotfiles personales para Arch Linux con [Omarchy](https://omarchy.org/) (Hyprland).

## Contenido

| Directorio | Descripción |
|---|---|
| `config/hypr/` | Hyprland (WM, keybindings, monitores, animaciones) |
| `config/waybar/` | Barra de estado (layout + CSS) |
| `config/nvim/` | Neovim (Lua config) |
| `config/kitty/` | Terminal Kitty |
| `config/alacritty/` | Terminal Alacritty |
| `config/ghostty/` | Terminal Ghostty |
| `config/walker/` | Lanzador de apps |
| `config/mako/` | Notificaciones |
| `config/btop/` | Monitor de sistema |
| `config/fastfetch/` | Info del sistema |
| `config/ranger/` | Gestor de archivos CLI |
| `config/lazygit/` | Git TUI |
| `config/git/` | Git global config |
| `config/starship.toml` | Prompt de shell |
| `home/` | `.bashrc`, `.bash_profile`, `.nanorc`, `.gitignore` |

## Instalación

```bash
git clone https://github.com/nickhernd/dot-files.git ~/dotfiles
cd ~/dotfiles
./install.sh
```

El script crea symlinks desde el repo hacia las ubicaciones correctas. Hace backup automático de cualquier archivo existente (`.bak`).

## Requisitos

- Arch Linux + [Omarchy](https://omarchy.org/)
- Hyprland, Waybar, Mako, Walker
- Neovim, Kitty/Alacritty/Ghostty
- Starship prompt
